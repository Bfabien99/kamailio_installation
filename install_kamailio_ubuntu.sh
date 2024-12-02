#!/bin/bash
## Installation de Kamailio sur un système Ubuntu
echo "## Début de l'installation de Kamailio sur votre système $1"
sleep 1

## Extraire le nom de code d'Ubuntu
if [[ -f /etc/os-release ]]; then
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo "Nom de code de votre Ubuntu : $codename"
else
    echo "XX Impossible de déterminer le nom de code. Assurez-vous que vous utilisez Ubuntu."
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
## Vérifier si Kamailio est déjà installé
echo "## Vérification de l'existence de Kamailio"
if [[ -x /usr/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
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
## Installation des dépendences réquises
echo "Installation des dépendances réquises: gnupg2 mariadb-server curl unzip"
echo "Installation de gnupg2"
if apt -y install gnupg2; then
    echo ":: gnupg2 a été installé avec succès."
else
    echo ":: L'installation de gnupg2 a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "Installation de mariadb-server"
if apt -y install mariadb-server; then
    echo ":: mariadb-server a été installé avec succès."
else
    echo ":: L'installation de mariadb-server a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "Installation de curl"
if apt -y install curl; then
    echo ":: curl a été installé avec succès."
else
    echo ":: L'installation de curl a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "Installation de unzip"
if apt -y install unzip; then
    echo ":: unzip a été installé avec succès."
else
    echo ":: L'installation de unzip a échoué." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi


sleep 1
## Ajout de la clé GPG de Kamailio
echo "Ajout de la clé GPG de Kamailio..."
wget -O- https://deb.kamailio.org/kamailiodebkey.gpg | apt-key add -
if [[ $? -ne 0 ]]; then
    echo ":: Échec de l'ajout de la clé GPG de Kamailio." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Clé GPG de Kamailio ajoutée avec succès."

sleep 1
## Ajouter les sources Kamailio à APT
echo "Ajout des sources Kamailio à votre fichier /etc/apt/sources.list.d/kamailio.list"
echo "deb http://cz.archive.ubuntu.com/ubuntu $codename main" | sudo tee -a /etc/apt/sources.list.d/kamailio.list > /dev/null
echo "deb http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list.d/kamailio.list > /dev/null
echo "deb-src http://deb.kamailio.org/kamailio58 $codename main" | sudo tee -a /etc/apt/sources.list.d/kamailio.list > /dev/null
if [[ $? -ne 0 ]]; then
    echo ":: Échec de l'ajout des sources Kamailio dans /etc/apt/sources.list.d/kamailio.list." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi
echo ":: Sources Kamailio ajoutées avec succès."

sleep 1
## Installation des dépendances requises
# Mettre à jour les dépôts APT
echo "Mise à jour des dépôts APT..."
if apt update -y; then
    echo "Mise à jour des dépôts réussie."
else
    echo "XX Erreur lors de la mise à jour des dépôts. Vérifiez votre connexion réseau ou vos sources APT." >&2
    echo "... "
fi

sleep 1
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
if [[ -x /usr/sbin/kamailio ]] || command -v kamailio >/dev/null 2>&1; then
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
