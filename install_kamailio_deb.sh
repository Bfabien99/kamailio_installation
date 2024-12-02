#!/bin/bash
## Installation de Kamailio sur un système Debian
echo "## Début de l'installation de Kamailio sur votre système $1"
sleep 1

## Extraire le nom de code de Debian
if [[ -f /etc/os-release ]]; then
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo "Nom de code de votre Debian : $codename"
else
    echo "XX Impossible de déterminer le nom de code. Assurez-vous que vous utilisez Debian."
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Vérifier si Kamailio est déjà installé
echo "## Vérification de l'existence de Kamailio"
if [[ -x /usr/local/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo ":: Kamailio est déjà installé sur ce système."
    echo "## Fin du programme d'installation de Kamailio"
    exit 0
fi

sleep 0.5
echo ":: Kamailio n'est pas installé sur ce système."
echo "## Installation de Kamailio sur votre distribution..."

sleep 0.5
## Vérifier que le script est lancé en mode root
if [[ $EUID -ne 0 ]]; then
    echo "XX Ce script doit être exécuté avec des privilèges root. Veuillez réessayer avec 'sudo'." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 1
## Installation des dépendances requises
# Mettre à jour les dépôts APT
echo "Mise à jour des dépôts APT..."
if apt update -y; then
    echo "Mise à jour des dépôts réussie."
else
    echo "XX Erreur lors de la mise à jour des dépôts. Vérifiez votre connexion réseau ou vos sources APT." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
# Mise à niveau des paquets installés
echo "Mise à niveau des paquets installés..."
if apt upgrade -y; then
    echo "Tous les paquets ont été mis à niveau avec succès."
else
    echo "XX Erreur lors de la mise à niveau des paquets. Vérifiez les journaux pour plus de détails." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Vérifier si wget est installé, sinon l'installer
if ! command -v wget >/dev/null 2>&1; then
    echo ":: wget n'est pas installé, installation en cours..."
    if apt install -y wget; then
        echo ":: wget a été installé avec succès."
    else
        echo ":: L'installation de wget a échoué." >&2
        echo "## Fin du programme d'installation"
        exit 1
    fi
else
    echo ":: wget est déjà installé sur ce système."
fi

sleep 1
## Ajout de la clé GPG de Kamailio
echo "Ajout de la clé GPG de Kamailio..."
wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | sudo apt-key add -
if [[ $? -ne 0 ]]; then
    echo ":: Échec de l'ajout de la clé GPG de Kamailio." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Clé GPG de Kamailio ajoutée avec succès."

sleep 1
## Ajouter les sources Kamailio à APT
echo "Ajout des sources Kamailio à votre fichier /etc/apt/sources.list..."
echo "deb http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list > /dev/null
echo "deb-src http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list > /dev/null
if [[ $? -ne 0 ]]; then
    echo ":: Échec de l'ajout des sources Kamailio dans /etc/apt/sources.list." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Sources Kamailio ajoutées avec succès."

sleep 1
## Installation de MySQL Server et Kamailio avec modules MySQL
echo "Installation de MySQL Server et des modules Kamailio MySQL..."
if apt -y install default-mysql-server; then
    echo ":: MySQL Server a été installé avec succès."
else
    echo ":: L'installation de MySQL Server a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
# Installation de Kamailio et des modules MySQL
if apt -y install kamailio kamailio-mysql-modules; then
    echo ":: Kamailio et les modules MySQL ont été installés avec succès."
else
    echo ":: L'installation de Kamailio et des modules MySQL a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
# Vérification de l'installation de Kamailio
if [[ -x /usr/local/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo "## Installation terminée."
    echo ":: Kamailio s'est bien installé sur ce système."
    echo "## Affichage de la version"
    command kamailio -V
    echo "## Démarrage de Kamailio"
    systemctl enable kamailio
    systemctl start kamailio
    echo ":: Kamailio a démarré avec succès."
    echo "## Fin du programme d'installation de Kamailio"
    exit 0
else
    echo ":: Kamailio n'a pas été installé correctement." >&2
    exit 1
fi