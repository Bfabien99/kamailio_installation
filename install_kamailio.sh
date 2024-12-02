#!/bin/bash

echo "Bienvenue dans le script d'installation de Kamailio."

# Vérifier la distribution du système
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo "Votre distribution est : $distribution"
    echo "Nom de code : $codename"
else
    echo "Impossible de déterminer la distribution. Assurez-vous que votre système utilise /etc/os-release."
    exit 1
fi

# Vérifier la distribution et exécuter le script approprié
if [[ "$distribution" == "debian" ]]; then
    echo "lancement du script ./install_kamailio_deb.sh"
    if [[ -f "./install_kamailio_deb.sh" ]]; then
        ./install_kamailio_deb.sh "$distribution"
    else
        echo "Erreur : Le script 'install_kamailio_deb.sh' est introuvable."
    fi
elif [[ "$distribution" == "ubuntu" ]]; then
    echo "lancement du script ./install_kamailio_ubuntu.sh"
    if [[ -f "./install_kamailio_ubuntu.sh" ]]; then
        ./install_kamailio_ubuntu.sh "$distribution"
    else
        echo "Erreur : Le script 'install_kamailio_ubuntu.sh' est introuvable."
    fi
else
    echo "Aucune installation disponible pour la distribution '$distribution'."
fi
