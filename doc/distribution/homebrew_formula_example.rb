# Exemple de formule Homebrew pour Sp3ctraGen
# Nom de fichier : sp3ctragen.rb
# À placer dans un tap Homebrew (dépôt)

class Sp3ctragen < Formula
  desc "Application de génération de spectrogrammes basée sur Qt Quick"
  homepage "https://github.com/votre-compte/sp3ctragen" # À remplacer par l'URL réelle de votre dépôt
  url "https://github.com/votre-compte/sp3ctragen/archive/refs/tags/v1.0.0.tar.gz" # À remplacer par l'URL de votre release
  sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef" # À remplacer par le SHA-256 de votre archive
  license "GPL-3.0" # À remplacer par votre licence
  
  # Dépendances
  depends_on "qt@5"
  depends_on "fftw"
  depends_on "cairo"
  depends_on "libsndfile"
  
  def install
    # Configurer avec qmake
    system "qmake", "Sp3ctraGen.pro", "CONFIG+=release"
    
    # Compiler
    system "make"
    
    # Installer l'application dans le préfixe Homebrew
    prefix.install "Sp3ctraGen.app"
    
    # Créer un lien symbolique pour l'exécutable dans bin/
    bin.install_symlink "#{prefix}/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen" => "sp3ctragen"
  end
  
  def caveats
    <<~EOS
      Sp3ctraGen a été installé dans:
        #{prefix}/Sp3ctraGen.app
      
      Pour lancer l'application, vous pouvez:
      - Ouvrir l'application depuis le Launchpad
      - Exécuter 'sp3ctragen' dans le terminal
      - Exécuter 'open #{prefix}/Sp3ctraGen.app'
    EOS
  end
  
  test do
    # Test de base pour vérifier que l'application existe et est exécutable
    assert_predicate "#{prefix}/Sp3ctraGen.app/Contents/MacOS/Sp3ctraGen", :exist?
  end
end