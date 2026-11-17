# Travaux pratiques — Ansible

Pour chaque exercice, rédigez et exécutez un playbook Ansible adapté. Utilisez l’inventaire fourni pour cibler les machines Alpine.

## 1. Vérifier la connexion aux machines

Écrivez un playbook qui vérifie la connexion à chaque machine Alpine avec le module `ping`. Vérifiez que chaque machine répond.

## 2. Afficher un message défini dans une variable

Définissez une variable contenant « Bonjour, Ansible! », puis affichez sa valeur. Modifiez le contenu de la variable et vérifiez que le message affiché change.

## 3. Afficher des messages selon une condition

Définissez une variable égale à « Bonjour ». Affichez un premier message si elle est égale à « Bonjour » et un autre si elle est différente. Modifiez la variable pour tester les deux cas.

## 4. Afficher les éléments d’une liste

Créez une liste de trois éléments et affichez chaque élément avec une boucle. Ajoutez un quatrième élément et vérifiez qu’il est aussi affiché.

## 5. Ajouter des utilisateurs à des machines

Ajoutez l’utilisateur Bob sur `alpine1` et l’utilisateur John sur `alpine2`. Vérifiez que chaque compte est créé uniquement sur la machine prévue, puis relancez le playbook et contrôlez le résultat.

## 6. Créer un fichier README pour chaque utilisateur

En vous appuyant sur les utilisateurs créés à l’exercice précédent, créez un fichier `README` dans le répertoire personnel de chacun. Le fichier doit contenir le titre « Bienvenue » et le nom de l’utilisateur. Vérifiez les fichiers sur les deux machines, puis modifiez le texte et vérifiez sa mise à jour.

## 7. Vérifier si Vim est installé

Vérifiez sur chaque machine Alpine si Vim est installé. Affichez un message indiquant s’il est installé ou non, sans interrompre l’exécution si Vim est absent.

## 8. Vérifier si Node.js est installé

Vérifiez sur chaque machine Alpine si Node.js est installé. Affichez son statut pour chaque machine, y compris lorsque Node.js est absent.

## 9. Installer plusieurs paquets

Installez `git`, `wget` et `tree` sur toutes les machines Alpine. Utilisez une boucle pour traiter la liste des paquets, puis vérifiez leur installation.

## 10. Installer 7-Zip sur une machine

Mettez à jour les dépôts de paquets sur `alpine1`, installez 7-Zip, puis vérifiez que la commande `7z` est disponible et affichez le résultat de la vérification.
