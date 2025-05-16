# Guide de visualisation des diagrammes Mermaid

Les diagrammes dans `schema_architecture_mvvm.md` sont créés avec [Mermaid](https://mermaid-js.github.io/mermaid/), un outil de création de diagrammes basé sur du texte. Voici comment les visualiser :

## 1. Dans VS Code (recommandé)

### Installation de l'extension

1. Ouvrez VS Code
2. Allez dans l'onglet Extensions (ou appuyez sur Ctrl+Shift+X / Cmd+Shift+X)
3. Recherchez "Markdown Preview Mermaid Support" 
4. Installez l'extension proposée par Matt Bierner

### Visualisation

1. Ouvrez le fichier Markdown (`schema_architecture_mvvm.md`)
2. Appuyez sur Ctrl+Shift+V (ou Cmd+Shift+V sur macOS) pour ouvrir la prévisualisation
3. Les diagrammes s'afficheront automatiquement

## 2. Utiliser l'éditeur en ligne Mermaid

1. Copiez le contenu d'un bloc de diagramme (le texte entre les balises \```mermaid et \```)
2. Accédez à [Mermaid Live Editor](https://mermaid-js.github.io/mermaid-live-editor/)
3. Collez le contenu dans l'éditeur
4. Le diagramme s'affichera dans le panneau de prévisualisation

Exemple pour le premier diagramme:
```
graph TD
    %% Définition des styles
    classDef qmlLayer fill:#f9a,stroke:#333,stroke-width:2px;
    classDef viewModelLayer fill:#ad9,stroke:#333,stroke-width:2px;
    classDef modelLayer fill:#adf,stroke:#333,stroke-width:2px;
    classDef cppLayer fill:#dad,stroke:#333,stroke-width:2px;
    classDef cLayer fill:#fea,stroke:#333,stroke-width:2px;

    %% Couche QML (Vue)
    QML[Interface QML \n main.qml + components] 
    QMLParams[SpectrogramParameters.qml]
    QMLFilter[FilterParameters.qml]
    QMLOutput[OutputFormat.qml]
    QMLAudio[AudioWaveformSection.qml]
    QMLPreview[PreviewSection.qml]

    %% Couche ViewModel (C++)
    VM[SpectrogramViewModel]

    %% Couche Modèle (C++)
    PM[SpectrogramParametersModel]

    %% Couche Logique C++
    SG[SpectrogramGenerator]
    VS[VisualizationStrategy]
    WF[WaveformProvider]
    IP[ImageProviders]
    TM[TaskManager]

    %% Couche Moteur C
    specgen[spectral_generator.c]
    specfft[spectral_fft.c]
    specvec[spectral_vector.c]
    specrast[spectral_raster.c]
    specwave[spectral_wav_processing.c]

    %% Connexions entre composants QML
    QML --> QMLParams
    QML --> QMLFilter
    QML --> QMLOutput
    QML --> QMLAudio
    QML --> QMLPreview

    %% Connexions QML -> ViewModel
    QMLParams -.->|Binding| VM
    QMLFilter -.->|Binding| VM
    QMLOutput -.->|Binding| VM
    QMLAudio -->|Extraction audio| VM
    QMLPreview -->|Actions utilisateur| VM

    %% Connexions QML -> Modèle
    QMLParams -.->|Binding| PM
    QMLFilter -.->|Binding| PM
    QMLOutput -.->|Binding| PM

    %% Connexions ViewModel -> Model
    VM -->|Accès et modification| PM

    %% Connexions ViewModel -> Logic C++
    VM -->|Délégation des appels| SG
    VM -->|Gestion tâches| TM
    
    %% Connexions Logic C++ -> Logic C++
    SG -->|Stratégie| VS
    SG -->|Tâches asynchrones| TM
    SG -->|Preview| IP
    
    %% Connexions Model -> Logic C++
    PM -.->|Structure de paramètres| SG

    %% Connexions Logic C++ -> Moteur C
    SG -->|Appels C| specgen
    VS -->|Appels C| specvec
    VS -->|Appels C| specrast
    WF -->|Appels C| specwave
    
    %% Connexions internes du Moteur C
    specgen -->|FFT| specfft
    specgen -->|Raster| specrast
    specgen -->|Vector| specvec
    specgen -->|Wave| specwave

    %% Application des styles
    class QML,QMLParams,QMLFilter,QMLOutput,QMLAudio,QMLPreview qmlLayer;
    class VM viewModelLayer;
    class PM modelLayer;
    class SG,VS,WF,IP,TM cppLayer;
    class specgen,specfft,specvec,specrast,specwave cLayer;
```

## 3. Exportation des diagrammes en images

Si vous souhaitez convertir les diagrammes en images pour les utiliser dans d'autres documents:

1. Utilisez le Mermaid Live Editor mentionné ci-dessus
2. Après avoir collé votre diagramme, cliquez sur le bouton "Download PNG"
3. Vous pouvez également télécharger en SVG ou d'autres formats

## 4. Intégration dans d'autres plateformes

- **GitHub**: Les diagrammes Mermaid sont automatiquement rendus dans les fichiers Markdown sur GitHub
- **GitLab**: Support natif des diagrammes Mermaid
- **Notion**: Support des diagrammes Mermaid dans les blocs de code
- **Confluence**: Avec des plugins appropriés

## 5. Génération de documentation avec diagrammes

Pour générer une documentation HTML avec les diagrammes Mermaid intégrés:

```bash
# Installer mkdocs avec support Mermaid
pip install mkdocs mkdocs-material
pip install pymdown-extensions

# Configurer mkdocs dans un fichier mkdocs.yml
# puis générer le site
mkdocs build
```

Cela créera un site web statique avec tous vos documents Markdown et les diagrammes Mermaid correctement rendus.
