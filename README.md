
# INSTALLATION DE KAMAILIO 5.8
Installation de kamailio sur différentes distributions.

## Installation
### Depuis la source (GIT)
Pour l'installation, veuillez exécuter le script
```install_from_source.sh```
```bash
  ./install_from_source.sh
```

### Depuis le package (debian et ubuntu)
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
```/usr/sbin``` pour l'intallation de puis la source source et ```/usr/local/sbin``` pour l'installation depuis les packages
- Pour utiliser les commandes de kamailio en ligne de commande, il faut inclure le chemin du binaire dans la variable d'environnement ```PATH```
```bash
  PATH=$PATH:/usr/local/sbin
  export PATH
```

Ce sont:
- ```kamailio``` - Exécutable principal du serveur SIP Kamailio
- ```kamdbctl``` - Script pour créer et gérer la base de données
- ```kamctl``` - Script pour gérer et contrôler le serveur SIP Kamailio
- ```kamcmd``` - Outil en ligne de commande (CLI) BINRPC pour interagir avec le serveur SIP Kamailio

## Fichiers
- Pour l'installation depuis la source, la racine des dossiers est ```/usr/local```
- Pour l'installation depuis les packages (apt), la racine des dossiers est ```/usr```

#### Depuis la source (GIT)
  - Sur un système d'exploitation 32 bits, les modules Kamailio sont installés dans :
  ```/usr/local/lib/kamailio/modules/```
  - Sur un système d'exploitation 64 bits, les modules Kamailio sont installés dans :
  ```/usr/local/lib64/kamailio/modules/```

  - Les fichiers de documentation et de readme sont installés dans :
  ```/usr/local/share/doc/kamailio/```

  - Les pages de manuel (man) sont installées dans :
  ```/usr/local/share/man/man5/```
  ```/usr/local/share/man/man8/```

#### Depuis le package (apt)
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
```/etc/kamailio/kamailio.cfg``` pour le package (apt)
```/usr/local/etc/kamailio/kamailio.cfg``` pour la source

## Quelques commandes
- verifier le path :
```which kamailio```

- verifier la version de kamailio installer :
```kamailio -V```

- verifier tous les modules disponibles
```apt search kamailio```

- comment installer le module kamailio-websocket:
```apt install kamailio-websocket-modules```

## Quelques configurations à faire pour utiliser kamailio avec MYSQL (exemple depuis la source)
### Création d'une base de données MySQL

Pour créer la base de données MySQL, vous devez utiliser le script de configuration de la base de données. Commencez par modifier le fichier **kamctlrc** pour définir le type de serveur de base de données :

```bash
nano -w /usr/local/etc/kamailio/kamctlrc
```

Repérez la variable **DBENGINE** et définissez-la sur **MYSQL** :

```bash
DBENGINE=MYSQL
```

Vous pouvez également modifier d'autres paramètres dans le fichier **kamctlrc**. Il est recommandé de changer les mots de passe par défaut des utilisateurs qui seront créés pour se connecter à la base de données.

> **Remarque :** Si la ligne contenant **DBENGINE** ou d'autres attributs est commentée (précédée d'un `#`), décommentez-la en supprimant le caractère `#` au début de la ligne.

Une fois les modifications terminées dans le fichier **kamctlrc**, exécutez le script pour créer la base de données utilisée par Kamailio :

```bash
/usr/local/sbin/kamdbctl create
```

Vous pouvez exécuter ce script sans paramètre pour obtenir de l'aide sur son utilisation. Il vous sera demandé le nom de domaine que Kamailio va desservir (par exemple : **mysipserver.com**) ainsi que le mot de passe de l'utilisateur root de MySQL. Le script va créer une base de données nommée **kamailio** contenant les tables nécessaires à Kamailio. Vous pouvez personnaliser les paramètres par défaut dans le fichier **kamctlrc** mentionné précédemment.

Le script ajoutera deux utilisateurs dans MySQL :

- **kamailio** - *(mot de passe par défaut : kamailiorw)* : utilisateur ayant tous les droits d'accès à la base de données **kamailio**.
- **kamailioro** - *(mot de passe par défaut : kamailioro)* : utilisateur ayant des droits d'accès en lecture seule à la base de données **kamailio**.

> **IMPORTANT :** Il est crucial de modifier les mots de passe de ces deux utilisateurs pour éviter d'utiliser les valeurs par défaut fournies avec les sources.

---

### Modification du fichier de configuration

Pour adapter la plateforme VoIP à vos besoins, vous devez modifier le fichier de configuration :

```bash
nano /usr/local/etc/kamailio/kamailio.cfg
```

Suivez les instructions dans les commentaires pour activer l'utilisation de MySQL. En général, vous devez ajouter plusieurs lignes en haut du fichier de configuration, comme :

```bash
#!define WITH_MYSQL
#!define WITH_AUTH
#!define WITH_USRLOCDB
```

Si vous avez modifié le mot de passe de l'utilisateur **kamailio** dans MySQL, mettez à jour la valeur des paramètres **db_url** en conséquence.

Vous pouvez également consulter **kamailio.cfg** en ligne dans le dépôt Git de Kamailio.


## Plus d'informations
- [Install Kamailio from source (GIT)](https://kamailio.org/docs/tutorials/5.8.x/kamailio-install-guide-git/)
- [Install Kamailio on debian with package](https://kamailio.org/docs/tutorials/devel/kamailio-install-guide-deb/)
- [Install Kamailio on ubuntu with package](https://www.atlantic.net/vps-hosting/how-to-install-kamailio-sip-server-on-ubuntu/)

## Authors
- [@bfabien99](https://www.github.com/bfabien99)