# TD — Installation et sécurisation d’une application web

### Application étudiée : https://github.com/rtxnak/todo-list

## Objectifs

- Installer et lancer l’application en local ou dans Docker.
- Concevoir une architecture réseau avec une DMZ et limiter les flux autorisés.
- Mettre en place et tester un contrôle de santé (*health check*).

## 1. Étude de l’application

1. Cloner le dépôt et lire son README et ses fichiers de configuration.
2. Identifier les dépendances, la commande de démarrage, le port utilisé et les paramètres nécessaires.
3. Vérifier si l’application fournit déjà un endpoint de santé. Ne pas supposer qu’un endpoint existe : le documenter ou proposer son ajout.

## 2. Installation — choisir une option

### Option A : installation locale

1. Installer les prérequis et dépendances indiqués par le projet.
2. Configurer puis démarrer l’application.
3. Vérifier son fonctionnement depuis un navigateur ou avec une requête HTTP.
4. Documenter les commandes d’installation, de démarrage et d’arrêt.

### Option B : Docker

1. Créer ou adapter un `Dockerfile` et, si nécessaire, un fichier `compose.yaml`.
2. Construire l’image, démarrer le conteneur et vérifier l’accès à l’application.
3. Exécuter le processus avec un utilisateur non privilégié lorsque l’application le permet. Ne placer aucun secret dans l’image ou dans le dépôt.
4. Documenter les commandes de construction, démarrage et arrêt.

## 3. Sécurité : architecture DMZ

Réaliser ou décrire une architecture de laboratoire comprenant une zone DMZ pour le service web exposé et une zone interne distincte pour les services qui ne doivent pas être accessibles directement. En environnement Docker, les zones peuvent être représentées par des réseaux séparés ; en installation locale, fournir un schéma et décrire les règles de pare-feu envisagées.

Appliquer le principe du moindre privilège :

- autoriser uniquement les flux indispensables et préciser leur source, destination, port et justification ;
- ne pas exposer les ports d’administration ni les services internes ;
- limiter les ports publiés par Docker au strict nécessaire ;
- conserver les secrets hors du dépôt et éviter leur apparition dans les journaux ;
- maintenir les composants à jour.

**À remettre :** un schéma réseau et un tableau des flux autorisés. Effectuer les essais uniquement dans un environnement contrôlé ; ne pas exposer le service sur Internet.

## 4. Contrôle de santé (*health check*)

1. Utiliser un endpoint de santé fourni par l’application ou proposer l’ajout d’un endpoint léger, par exemple `/health`, qui renvoie HTTP `200` lorsque le service est disponible.
2. Configurer un contrôle périodique. Avec Docker, utiliser `HEALTHCHECK` ou la propriété `healthcheck` de Compose ; en local, utiliser un outil ou une commande de vérification HTTP.
3. Tester le résultat lorsque l’application fonctionne, puis lorsqu’elle est arrêtée ou indisponible. Présenter les commandes et résultats obtenus.
4. Expliquer pourquoi un processus démarré n’est pas nécessairement un service prêt à recevoir des requêtes.

Le contrôle de santé ne doit révéler ni secret ni détail interne sensible.

