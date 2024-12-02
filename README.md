
# INSTALLATION DE KAMAILIO 5.8
Installation de kamailio sur différentes distributions.
Les distributions prises en charge actuellement sont ```debian``` et ```ubuntu```

## Installation
Pour l'installation, vous pouvez directement lancer le fichier correspondant à votre distribution
- Pour ```debian``` lancer le fichier ```install_kamailio_deb.sh```

```bash
  ./install_kamailio_deb.sh
```
Ou lancer le fichier ```install_kamailio.sh``` qui installera kaimailo en fonction de votre distribution 
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
```/usr/sbin```

Ce sont:
- ```kamailio``` - Exécutable principal du serveur SIP Kamailio
- ```kamdbctl``` - Script pour créer et gérer la base de données
- ```kamctl``` - Script pour gérer et contrôler le serveur SIP Kamailio
- ```kamcmd``` - Outil en ligne de commande (CLI) BINRPC pour interagir avec le serveur SIP Kamailio

## Fichiers
- Sur un système d'exploitation 32 bits, les modules Kamailio sont installés dans :
```/usr/lib/kamailio/modules/```

- Sur un système d'exploitation 64 bits, les modules Kamailio sont installés dans :
```/usr/lib64/kamailio/modules/```  ou  ```/usr/lib/x86_64-linux-gnu/kamailio/modules/```

- Les fichiers de documentation et de readme sont installés dans :
```/usr/share/doc/kamailio/```

- Les pages de manuel (man) sont installées dans :
```/usr/share/man/man5/```
```/usr/share/man/man8/```

- Le fichier de configuration est installé dans :
```/etc/kamailio/kamailio.cfg```

## Plus d'informations
- [Kaimailio on debian](https://kamailio.org/docs/tutorials/devel/kamailio-install-guide-deb/)
- [Kaimailio on ubuntu](https://www.atlantic.net/vps-hosting/how-to-install-kamailio-sip-server-on-ubuntu/)

## Authors
- [@bfabien99](https://www.github.com/bfabien99)