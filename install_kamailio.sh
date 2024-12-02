#!/bin/bash

# Fonction pour collecter les informations de l'utilisateur
echo "Bienvenue dans le script d'installation de Kamailio."
echo "Avant de continuer, je vais vous poser quelques questions."

# Demander la distribution
distribution=""
while [[ "$distribution" != "debian" && "$distribution" != "ubuntu" ]]; do
    echo -n "1. Quelle est votre distribution (debian/ubuntu) ? "
    read -r distribution
    if [[ "$distribution" != "debian" && "$distribution" != "ubuntu" ]]; then
        echo "Veuillez entrer 'debian' ou 'ubuntu'."
    fi
done

# Demander la version
echo -n "2. Quelle est la version ? "
read -r version

# Afficher les résultats
echo "## Distribution = $distribution | Version = $version"

# Vérifier la distribution et exécuter le script approprié
if [[ "$distribution" == "debian" ]]; then
    if [[ -f "./install_kamailio_deb.sh" ]]; then
        ./install_kamailio_deb.sh "$distribution"
    else
        echo "Erreur : Le script 'install_kamailio_deb.sh' est introuvable."
    fi
else
    echo "Aucune installation disponible pour la distribution '$distribution'."
fi
