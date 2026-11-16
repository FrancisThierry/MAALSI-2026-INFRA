
### Qu'est-ce que `wslc` ?

Introduit par Microsoft au sein de l'écosystème WSL, **`wslc`** est un outil de ligne de commande natif (`wslc.exe`) intégré au sous-système Windows pour Linux.

* **Son objectif :** Offrir une expérience de conteneurisation légère et directe sous Windows.
* **Ses avantages :** Il s'affranchit de la lourdeur de Docker Desktop et évite d'avoir à configurer manuellement un démon Docker ou un systemd au sein d'une distribution Linux classique. Les conteneurs profitent directement du pont réseau virtuel et du moteur de virtualisation de WSL.

---

### Comment obtenir et installer `wslc` ?

Pour disposer de cette fonctionnalité et de la commande `wslc`, votre environnement Windows et votre version de WSL doivent être à jour. Voici la procédure :

1. **Mettre à jour WSL vers la dernière version:** Mise à jour requise.
Ouvrez **PowerShell en tant qu'administrateur** pour forcer la mise à jour des composants WSL (nécessite une version récente de WSL incluant le support des conteneurs natifs) :

```powershell
wsl --update
wsl --shutdown

```

*Verification:* Fermez et rouvrez votre terminal, puis tapez `wsl --version`. Vérifiez que votre version est bien récente (comme la version 3.0.5.0 ou supérieure).


2. **Actualiser l'environnement de développement:** Validation de l'outil.
Si vous utilisez un éditeur comme **VS Code**, pensez à le **fermer complètement et à le relancer** pour qu'il prenne en compte les nouveaux chemins (`PATH`) et les nouvelles commandes système de votre invite de commande.
*Verification:* Tapez `wslc --version` (ou `wslc`) dans votre terminal VS Code pour valider que la commande répond correctement.


---
Voici comment créer et rédiger votre fichier de configuration (`Containerfile` ou `my_machine.dockerfile`) pour construire votre image Alpine personnalisée avec `wslc`.

### 1. Créer le fichier de configuration

Dans votre dossier de projet (`TD_alpine_network`), créez un fichier texte nommé exactement **`my_machine.dockerfile`**.

### 2. Contenu du fichier de configuration

Ouvrez ce fichier dans votre éditeur (comme VS Code) et collez le contenu minimaliste suivant, qui ajoute les outils réseau indispensables (comme `iputils` pour `ping` et `curl`) :

```dockerfile
# Utiliser l'image officielle Alpine la plus récente
FROM alpine:latest

# Mettre à jour les paquets et installer les utilitaires réseau de base
RUN apk update && apk add --no-cache \
    iputils \
    iproute2 \
    curl \
    tcpdump \
    socat

# Définir le répertoire de travail par défaut
WORKDIR /app

# Lancer un shell par défaut au démarrage du conteneur
CMD ["sh"]

```

---

### 3. Construire et tester l'image avec `wslc`

Une fois votre fichier enregistré, retournez dans votre terminal VS Code (placé dans le dossier du projet) et lancez la commande de construction :

```powershell
wslc build -t mon-alpine -f .\my_machine.dockerfile .

```

*Verification:* Le terminal télécharge l'image de base Alpine et exécute les instructions de votre fichier étape par étape.

Pour tester immédiatement votre image avec les outils réseau intégrés :

```powershell
wslc run --rm -it mon-alpine sh

```

Une fois à l'intérieur du conteneur, vous pouvez tester vos commandes réseau (par exemple `ping 8.8.8.8` ou `ip addr show`).

### Utilisation de base avec `wslc`

Une fois l'outil opérationnel, vous pouvez gérer vos conteneurs et vos fichiers de configuration (`Containerfile` ou `Dockerfile`) directement depuis Windows :

* **Construire une image (ex: Alpine personnalisée) :**
```powershell
wslc build -t mon-alpine -f .\my_machine.dockerfile .

```


* **Lancer un conteneur interactif :**
```powershell
wslc run --rm -it mon-alpine sh

```


* **Créer un réseau virtuel local (LAN) entre conteneurs :**
```powershell
wslc network create --driver bridge mon-reseau-interne

```

### Tester un ping d'Alpine 1 vers Alpine 2

Après avoir construit l'image `mon-alpine` et créé le réseau `mon-reseau-interne`, lancez les deux conteneurs sur ce réseau :

```powershell
wslc run -d --name alpine1 --network mon-reseau-interne mon-alpine sleep infinity
wslc run -d --name alpine2 --network mon-reseau-interne mon-alpine sleep infinity
```

Ouvrez un terminal dans Alpine 1, puis envoyez quatre requêtes ping à Alpine 2 en utilisant son nom de conteneur :

```powershell
wslc exec -it alpine1 sh
ping -c 4 alpine2
```

Des réponses indiquent que les conteneurs communiquent. Si `ping` ne répond pas, vérifiez que les deux conteneurs sont démarrés et attachés à `mon-reseau-interne`. Quittez le shell avec `exit`, puis supprimez les conteneurs après le test :

```powershell
wslc rm -f alpine1 alpine2
```


```mermaid
architecture-beta
    group host(cloud)[Hote Windows et WSL 2]
    group lan(internet)[Reseau Virtuel Bridge - LAN]

    service vscode(server)[VS Code et wslc CLI] in host
    service bridge(internet)[Pont Reseau WSLC] in lan
    service alpine1(server)[alpine-machine-1] in lan
    service alpine2(server)[alpine-machine-2] in lan
    service wan(cloud)[Internet Externe]

    vscode:B --> T:bridge
    bridge:B -- T:alpine1
    bridge:B -- T:alpine2
    alpine1:R <--> L:alpine2
    bridge:R --> L:wan

```

