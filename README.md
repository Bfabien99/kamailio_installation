
# INSTALLATION DE KAMAILIO 5.8
Installation de kamailio sur différentes distributions.
La distribution prise en charge actuellement est ```debian```

## Installation
Pour l'installation, vous pouvez directement lancer le fichier correspondant à votre distribution
- Pour ```debian``` lancer le fichier ```install_kamailio_deb.sh```

```bash
  ./install_kamailio_deb.sh
```
Ou lancer le fichier ```install_kamailio.sh``` et suivre les étapes 
```bash
    ./install_kamailio.sh
```
Il faudra exécuter les différents fichiers en mode ```root```

## Comment lancer Kamailio
- Pour activer ```kamailio``` utiliser la commande
```systemctl enable kamailio```
- Pour démarrer ```kamailio``` utiliser la commande
```systemctl start kamailio```
- Pour stopper ```kamailio``` utiliser la commande
```systemctl stop kamailio```


## Kamailio binaries
Les fichiers binaires de Kamailio et les scripts exécutables (outils) sont installés dans:
```/usr/local/sbin```

Ce sont:
- ```kamailio``` - Exécutable principal du serveur SIP Kamailio
- ```kamdbctl``` - Script pour créer et gérer la base de données
- ```kamctl``` - Script pour gérer et contrôler le serveur SIP Kamailio
- ```kamcmd``` - Outil en ligne de commande (CLI) BINRPC pour interagir avec le serveur SIP Kamailio

## Fichiers
- Sur un système d'exploitation 32 bits, les modules Kamailio sont installés dans :
```/usr/local/lib/kamailio/modules/```

- Sur un système d'exploitation 64 bits, les modules Kamailio sont installés dans :
```/usr/local/lib64/kamailio/modules/```

- Les fichiers de documentation et de readme sont installés dans :
```/usr/local/share/doc/kamailio/```

- Les pages de manuel (man) sont installées dans :
```/usr/local/share/man/man5/```
```/usr/local/share/man/man8/```

- Le fichier de configuration est installé dans :
```/usr/local/etc/kamailio/kamailio.cfg```

## Plus d'informations
- [Kaimailio on debian](https://kamailio.org/docs/tutorials/devel/kamailio-install-guide-deb/)

## Authors
- [@bfabien99](https://www.github.com/bfabien99)