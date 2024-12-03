#!/bin/bash

echo "## Bienvenue dans le script d'installation de Kamailio 5.8."
sleep 0.5

## Vérifier que le script est lancé en mode root
if [[ $EUID -ne 0 ]]; then
    echo ":: XX Ce script doit être exécuté avec des privilèges root. Veuillez réessayer avec 'sudo'." >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

# Vérifier la distribution du système
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo ":: Detail du système"
    echo ":: Votre distribution est : $distribution"
    echo ":: Nom de code : $codename"
else
    echo ":: XX Impossible de déterminer la distribution. Assurez-vous que votre système utilise /etc/os-release. XX"
    exit 1
fi

## Installation de Kamailio
sleep 0.5
echo "## Installation de Kamailio"
sleep 0.5

## Mettre à jour les dépôts APT
echo "## Mise à jour des dépôts APT..."
sleep 0.5
if apt update -y; then
    echo ":: Mise à jour des dépôts réussie."
else
    echo ":: XX Erreur lors de la mise à jour des dépôts. Vérifiez votre connexion réseau ou vos sources APT. XX" >&2
    echo "..."
fi

## Installation des dépendances requises
sleep 0.5
echo "## Installation des dépendances requises"
sleep 0.5
echo "## Installation de make"
sleep 0.5
if apt -y install make; then
    echo ":: make a été installé avec succès."
else
    echo ":: XX L'installation de make a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de autoconf"
sleep 0.5
if apt -y install autoconf; then
    echo ":: autoconf a été installé avec succès."
else
    echo ":: XX L'installation de autoconf a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de pkg-config"
sleep 0.5
if apt -y install pkg-config; then
    echo ":: pkg-config a été installé avec succès."
else
    echo ":: XX L'installation de pkg-config a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de git"
sleep 0.5
if apt -y install git; then
    echo ":: git a été installé avec succès."
else
    echo ":: XX L'installation de git a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de gcc"
sleep 0.5
if apt -y install gcc; then
    echo ":: gcc a été installé avec succès."
else
    echo ":: XX L'installation de gcc a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de g++"
sleep 0.5
if apt -y install g++; then
    echo ":: g++ a été installé avec succès."
else
    echo ":: XX L'installation de g++ a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de flex"
sleep 0.5
if apt -y install flex; then
    echo ":: flex a été installé avec succès."
else
    echo ":: XX L'installation de flex a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de bison"
sleep 0.5
if apt -y install bison; then
    echo ":: bison a été installé avec succès."
else
    echo ":: XX L'installation de bison a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de libssl-dev"
sleep 0.5
if apt -y install libssl-dev; then
    echo ":: libssl-dev a été installé avec succès."
else
    echo ":: XX L'installation de libssl-dev a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

sleep 0.5
echo "## Installation de default-libmysqlclient-dev"
sleep 0.5
if apt -y install default-libmysqlclient-dev; then
    echo ":: default-libmysqlclient-dev a été installé avec succès."
else
    echo ":: XX L'installation de default-libmysqlclient-dev a échoué. XX" >&2
    echo "## Fin du programme d'installation"
    exit 1
fi

## Création du dossier pour stocker kamailio
sleep 0.5
echo "## Création du dossier /usr/local/src/kamailio-5.8"
mkdir -p /usr/local/src/kamailio-5.8
echo ":: Dossier créer"
sleep 0.5
echo "## Clonage du repo git dans /usr/local/src/kamailio-5.8"
cd /usr/local/src/kamailio-5.8
git clone --depth 1 --branch 5.8 https://github.com/kamailio/kamailio kamailio
cd kamailio
echo ":: clonage réussi"

sleep 0.5
echo "## ajout du module db_mysql et tls"
make include_modules="db_mysql tls" cfg
make all
make install
su -l
make install-systemd-debian
systemctl enable kamailio
systemctl daemon-reload