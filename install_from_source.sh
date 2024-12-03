#!/bin/bash

echo "## Bienvenue dans le script d'installation de Kamailio 5.8."
sleep 0.5

## Vérifier que le script est lancé en mode root
if [[ $EUID -ne 0 ]]; then
    echo ":: XX Ce script doit être exécuté avec des privilèges root. Veuillez réessayer avec 'sudo'." >&2
    exit 1
fi

## Vérifier la distribution
if [[ -f /etc/os-release ]]; then
    distribution=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    codename=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
    echo ":: Détails du système : $distribution ($codename)"
else
    echo ":: XX Impossible de déterminer la distribution. Assurez-vous que votre système utilise /etc/os-release. XX"
    exit 1
fi

## Mettre à jour les dépôts APT
echo "## Mise à jour des dépôts APT..."
sleep 0.5
if ! apt update -y; then
    echo ":: XX Échec lors de la mise à jour des dépôts APT. XX" >&2
    exit 1
fi

## Installation des dépendances
echo "## Installation des dépendances requises..."
sleep 0.5
deps=(make autoconf pkg-config git gcc g++ flex bison libssl-dev default-libmysqlclient-dev)

for dep in "${deps[@]}"; do
    echo "Installation de $dep..."
    if ! apt install -y "$dep"; then
        echo ":: XX L'installation de $dep a échoué. XX" >&2
        exit 1
    fi
    sleep 0.5
done

## Création du dossier de stockage
echo "## Préparation du dossier pour Kamailio..."
kamailio_src="/usr/local/src/kamailio-5.8"
if [[ ! -d $kamailio_src ]]; then
    mkdir -p "$kamailio_src"
    echo ":: Dossier créé : $kamailio_src"
else
    echo ":: Dossier déjà existant : $kamailio_src"
fi

## Clonage du dépôt Git
echo "## Clonage du dépôt Kamailio dans $kamailio_src..."
cd "$kamailio_src"
if ! git clone --depth 1 --branch 5.8 https://github.com/kamailio/kamailio kamailio; then
    echo ":: XX Échec du clonage du dépôt Git. Vérifiez votre connexion réseau. XX" >&2
    exit 1
fi
cd kamailio

## Compilation et installation
echo "## Compilation et installation de Kamailio avec les modules db_mysql et tls..."
if ! make include_modules="db_mysql tls" cfg || ! make all || ! make install; then
    echo ":: XX La compilation ou l'installation de Kamailio a échoué. XX" >&2
    exit 1
fi

# Vérifier et ajouter l'utilisateur système 'kamailio'
echo "Ajout de l'utilisateur système kamailio..."
if /usr/sbin/adduser --system --group --no-create-home kamailio >/dev/null 2>&1; then
    echo ":: Utilisateur 'kamailio' ajouté avec succès."
else
    echo ":: XX Échec avec adduser, tentative avec useradd... XX"
    if ! /usr/sbin/useradd -r -M -s /bin/false kamailio >/dev/null 2>&1; then
        echo ":: XX Échec complet lors de l'ajout de l'utilisateur système. XX" >&2
        exit 1
    fi
fi

## Configuration des services systemd
echo "## Configuration des services systemd pour Kamailio..."
if ! make install-systemd-debian || ! systemctl enable kamailio; then
    echo ":: XX La configuration de Kamailio avec systemd a échoué. XX" >&2
    exit 1
fi
systemctl daemon-reload

## Fin
echo "## Installation et configuration de Kamailio terminées."
echo ":: Vous pouvez démarrer Kamailio avec 'systemctl start kamailio'."
exit 0