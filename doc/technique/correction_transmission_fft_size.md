# Correction de la transmission de la taille FFT

Ce document décrit le correctif apporté pour résoudre un problème où la taille FFT calculée par le curseur de résolution n'était pas correctement transmise au moteur de génération du spectrogramme.

## Problème identifié

Lors des tests, il a été observé que lorsque l'utilisateur modifiait la position du curseur de résolution:

1. L'interface utilisateur affichait correctement les nouvelles valeurs calculées (FFT Size, Overlap)
2. Le modèle `SpectrogramParametersModel` calculait correctement la taille FFT
3. Mais le moteur de génération du spectrogramme utilisait toujours les mêmes paramètres FFT (1024, Medium overlap)

Ceci indiquait une rupture dans la chaîne de transmission des paramètres calculés par le curseur vers le moteur de génération.

## Analyse du problème

L'analyse des logs a révélé le problème suivant:

```
// Dans l'interface QML
FFT parameters updated: FFT Size = 256, Overlap = 0.375

// Mais dans le moteur de génération
Initialized FFT with size 1024, Overlap = Medium (0.75)
```

Le problème résidait dans le fait que:

1. Le `SpectrogramParametersModel` calculait correctement les paramètres optimaux
2. La structure `SpectrogramSettings` ne contenait pas de champ pour stocker la taille FFT calculée
3. Le fichier `spectral_raster.c` recalculait systématiquement la taille FFT sans utiliser celle calculée par le modèle

## Solution implémentée

La solution a consisté à ajouter un nouveau champ à la structure des paramètres et à assurer sa propagation correcte à travers les différentes couches du logiciel:

### 1. Ajout d'un champ dans la structure C

```c
typedef struct SpectrogramSettings
{
    // Champs existants...
    
    int     fftSize;             // FFT size (0 = auto-calculate)
    
    // Autres champs...
} SpectrogramSettings;
```

### 2. Ajout d'un champ et accesseurs dans la classe C++

```cpp
class SpectrogramSettingsCpp {
private:
    // Autres champs...
    int m_fftSize;  // Taille FFT calculée par le curseur de résolution (0=auto)
    
public:
    // Accesseurs
    int getFftSize() const { return m_fftSize; }
    void setFftSize(int value) { m_fftSize = value; }
    
    // Autres méthodes...
}
```

### 3. Mise à jour des méthodes de conversion

```cpp
// Dans SpectrogramSettingsCpp::toCStruct()
SpectrogramSettings cSettings;
// [...]
cSettings.fftSize = m_fftSize; // Transfert de la taille FFT calculée

// Dans SpectrogramSettingsCpp::fromCStruct()
settings.m_fftSize = cSettings.fftSize; // Récupération de la taille FFT
```

### 4. Transmission de la taille FFT dans le modèle

```cpp
// Dans SpectrogramParametersModel::toCStruct()
settings.binsPerSecond = m_cachedBps;
settings.overlapPreset = m_overlapPreset;
settings.fftSize = m_cachedFftSize; // Transmettre la taille FFT calculée
```

### 5. Utilisation prioritaire dans le générateur

```cpp
// Dans spectrogramgenerator.cpp
int calculatedFftSize;
if (settings.getFftSize() > 0) {
    // Utiliser la taille FFT précalculée si disponible
    calculatedFftSize = settings.getFftSize();
    qDebug() << " - Using provided FFT size:" << calculatedFftSize << "from resolution model";
} else {
    // Sinon calculer la taille FFT à partir des paramètres courants
    calculatedFftSize = settings.calculateFftSize(sampleRate);
    qDebug() << " - Calculated FFT size:" << calculatedFftSize << "(from bins/s=" << binsPerSecond << ")";
}

// Stocker la valeur calculée pour qu'elle soit transmise au moteur de génération
settings.setFftSize(calculatedFftSize);
```

### 6. Respect de la valeur fournie dans le moteur

```c
// Dans spectral_raster.c
if (cfg->fftSize > 0) {
    // Si fftSize est spécifié, nous utilisons directement cette valeur
    fft_size = cfg->fftSize;
    printf(" - Using precalculated FFT size: %d (from resolution slider)\n", fft_size);
} else {
    // Sinon, nous utilisons la méthode de calcul traditionnelle
    printf(" - Calculated FFT size: %d (from bins/s=%.1f, overlap=%.2f)\n",
           fft_size, binsPerSecond, overlapValue);
}
```

## Résultat et validation

Après ces modifications, la taille FFT calculée par le curseur de résolution est correctement transmise au moteur de génération du spectrogramme:

1. La position "Temporel" (0.0) du curseur produit maintenant des spectrogrammes avec une petite taille FFT (256-512)
2. La position "Équilibrée" (0.5) utilise une taille FFT moyenne (2048)
3. La position "Spectral" (1.0) génère des spectrogrammes avec une grande taille FFT (8192-16384)

Cette correction respecte l'algorithme de génération adaptative pilotée par curseur spécifié, où l'utilisateur peut contrôler intuitivement le compromis entre résolution temporelle et fréquentielle.

## Impact sur les performances

Ce changement n'a pas d'impact significatif sur les performances, car:

1. La taille FFT est calculée une seule fois par le modèle
2. La valeur calculée est simplement transmise au moteur de génération
3. Cela évite une recalculation inutile et garantit la cohérence des paramètres

## Intégration avec l'adaptation au taux d'échantillonnage

Cette modification s'intègre parfaitement avec l'adaptation au taux d'échantillonnage implémentée précédemment:

1. Le modèle `SpectrogramParametersModel` calcule une taille FFT adaptée au taux d'échantillonnage
2. Cette taille est transmise au générateur et utilisée telle quelle
3. Le résultat visuel reste cohérent quel que soit le taux d'échantillonnage

Cette correction complète l'implémentation du système de résolution adaptative et garantit que les intentions de l'utilisateur, exprimées à travers la position du curseur, sont correctement appliquées dans le spectrogramme généré.
