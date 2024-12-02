#!/bin/bash

## Vérifier que le script est lancé en mode root
if [[ $EUID -ne 0 ]]; then
    echo ":: XX Ce script doit être exécuté avec des privilèges root. Veuillez réessayer avec 'sudo'. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

## Installation de Kamailio sur un système Debian
echo "## Début de l'installation de Kamailio sur votre système $1"
sleep 0.5

## Extraire le nom de code de Debian
if [[ -f /etc/os-release ]]; then
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
else
    echo ":: XX Impossible de déterminer le nom de code. Assurez-vous que vous utilisez Debian. XX"
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Vérifier si Kamailio est déjà installé
echo "## Vérification de l'existence de Kamailio"
if [[ -x /usr/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo ":: Kamailio est déjà installé sur ce système."
    sleep 0.5
    command kamailio -V
    sleep 0.5
    echo "## Fin du programme d'installation de Kamailio"
    exit 0
fi

sleep 0.5
echo ":: Kamailio n'est pas installé sur ce système."
echo "## Installation de Kamailio sur votre distribution..."

sleep 0.5
## Vérifier si wget est installé, sinon l'installer
if ! command -v wget >/dev/null 2>&1; then
    echo ":: wget n'est pas installé, installation en cours..."
    if apt install -y wget; then
        echo ":: wget a été installé avec succès."
    else
        echo ":: XX L'installation de wget a échoué. XX" >&2
        echo "## Fin du programme d'installation"
        exit 1
    fi
else
    echo ":: wget est déjà installé sur ce système."
fi

sleep 0.5
## Ajout de la clé GPG de Kamailio
echo "## Ajout de la clé GPG de Kamailio..."
sleep 0.5
wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | sudo apt-key add -
if [[ $? -ne 0 ]]; then
    echo ":: XX Échec de l'ajout de la clé GPG de Kamailio. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Clé GPG de Kamailio ajoutée avec succès."

sleep 0.5
## Ajouter les sources Kamailio à APT
echo "## Ajout des sources Kamailio à votre fichier /etc/apt/sources.list..."
sleep 0.5
echo "deb http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list > /dev/null
echo "deb-src http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list > /dev/null
if [[ $? -ne 0 ]]; then
    echo ":: XX Échec de l'ajout des sources Kamailio dans /etc/apt/sources.list. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Sources Kamailio ajoutées avec succès."

sleep 0.5
## Installation des dépendances requises
# Mettre à jour les dépôts APT
echo "## Mise à jour des dépôts APT..."
sleep 0.5
if apt update -y; then
    echo ":: Mise à jour des dépôts réussie."
else
    echo ":: XX Erreur lors de la mise à jour des dépôts. Vérifiez votre connexion réseau ou vos sources APT. XX" >&2
    echo "..."
fi

sleep 0.5
## Installation de MySQL Server et Kamailio avec modules MySQL
echo "## Installation de MySQL Server et des modules Kamailio MySQL..."
sleep 0.5
if apt -y install default-mysql-server; then
    echo ":: MySQL Server a été installé avec succès."
else
    echo ":: L'installation de MySQL Server a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Installation de Kamailio et des modules MySQL
echo "## Installation de Kamailio et des modules MySQL"
sleep 0.5
if apt -y install kamailio kamailio-mysql-modules; then
    echo ":: Kamailio et les modules MySQL ont été installés avec succès."
else
    echo ":: L'installation de Kamailio et des modules MySQL a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Vérification de l'installation de Kamailio
if [[ -x /usr/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
    echo "## Installation terminée."
    sleep 0.5
    command kamailio -V
    sleep 0.5
    echo ":: Kamailio s'est bien installé sur ce système."
    sleep 0.5
    echo "## Démarrage de Kamailio"
    sleep 0.5
    systemctl enable kamailio
    systemctl start kamailio
    sleep 0.5
    echo ":: Kamailio a démarré avec succès."
    sleep 0.5
    echo "## Fin de l'installation de Kamailio"
    exit 0
else
    echo ":: Kamailio n'a pas été installé correctement." >&2
    exit 1
fi

sleep 0.5
echo "## Ajout des binaires dans le PATH"
sleep 0.5
# Ajout de /usr/sbin au PATH s'il n'est pas déjà présent
if [[ ":$PATH:" != *":/usr/sbin:"* ]]; then
    PATH=$PATH:/usr/sbin
    export PATH
    echo ":: Le dossier /usr/sbin a été ajouté au PATH."
else
    echo ":: Le dossier /usr/sbin est déjà dans le PATH."
fi
sleep 0.5
echo ":: Un redémarrage peut être nécessaire pour que tout prenne effet."
echo "## Fin du programme d'installation de Kamailio"
