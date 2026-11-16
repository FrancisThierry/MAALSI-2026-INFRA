# TD — Découvrir un réseau avec Alpine Linux

## Objectifs

- Ajouter une machine Alpine au réseau du laboratoire.
- Examiner sa configuration et découvrir les équipements voisins.
- Vérifier le DNS et effectuer une requête `curl` vers Google.

## Prérequis

Docker et Docker Compose sont installés. Le réseau Docker `lan` existe déjà et est accessible depuis le laboratoire. Adaptez son nom si nécessaire.

## 1. Ajouter et démarrer Alpine

Ajoutez ce service à votre fichier `compose.yaml` :

```yaml
services:
	alpine:
		image: alpine:latest
		container_name: alpine-td
		command: ["sh", "-c", "while true; do sleep 3600; done"]
		networks:
			- lan

networks:
	lan:
		external: true
```

Si une section `networks` existe déjà, complétez-la au lieu de la remplacer. Lancez le conteneur et ouvrez un shell :

```sh
docker compose up -d alpine
docker compose exec alpine sh
```

Installez les outils réseau dans le conteneur :

```sh
apk add --no-cache iproute2 iputils bind-tools curl
```

## 2. Examiner la configuration

Exécutez les commandes suivantes :

```sh
ip addr
ip route
cat /etc/resolv.conf
```

Notez l’adresse IPv4 d’Alpine, le préfixe du réseau, la passerelle par défaut et le serveur DNS.

## 3. Découvrir les équipements du réseau

À partir de la sortie de `ip route`, remplacez `<passerelle>` par l’adresse de la passerelle :

```sh
ping -c 3 <passerelle>
ip neigh
```

Relevez les adresses et les états des voisins affichés. La table peut être vide ou incomplète avant tout échange réseau. Limitez vos tests aux équipements du réseau de laboratoire.

## 4. Tester le DNS et Google

```sh
nslookup google.com
curl -I --max-time 10 https://www.google.com
```

Indiquez l’adresse IP retournée par le DNS et le code HTTP observé. Si la requête échoue, précisez si le problème semble concerner la résolution DNS, la passerelle ou l’accès Internet.

## À rendre

Remettez les réponses aux questions, les sorties utiles des commandes et une courte conclusion sur la connectivité de la machine Alpine.
