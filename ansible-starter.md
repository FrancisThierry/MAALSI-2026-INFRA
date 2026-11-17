
## Tutoriel : Monter un environnement de TP Ansible avec Docker et Alpine sous WSL

### 1. Prérequis système (WSL Ubuntu)

1. **Installer Ansible, Docker et Docker Compose V2**
```bash
sudo apt update
sudo apt install -y ansible-core docker.io docker-compose-v2

```


*Vérification :* `ansible --version` et `docker compose version` affichent leurs numéros de version respectifs sans erreur.
2. **Démarrer le service Docker et autoriser ton utilisateur**
```bash
sudo service docker start
sudo usermod -aG docker $USER
su - $USER

```


*(Astuce : si tu ouvres un nouveau terminal WSL plus tard, un `wsl --shutdown` sous PowerShell permet d'appliquer définitivement l'appartenance au groupe `docker` sans avoir à refaire `su - $USER`.)*
*Vérification :* Exécute `docker ps` (sans `sudo`). La commande doit s'exécuter sans erreur `permission denied`.

---

### 2. Créer l'espace de travail

1. **Créer et ouvrir le dossier du projet**
```bash
mkdir -p ~/ansible-workspace
cd ~/ansible-workspace
code .

```


*Vérification :* VS Code s'ouvre directement à la racine du dossier `~/ansible-workspace`.

---

### 3. Créer les fichiers de configuration (à copier-coller dans VS Code)

Crée les quatre fichiers suivants à la racine de `~/ansible-workspace` en respectant exactement la casse (notamment le **D** majuscule de `Dockerfile`, sans extension).

#### A. `Dockerfile`

Installe uniquement `python3` (pour exécuter les modules Ansible) et `shadow` (pour fournir `useradd`/`usermod` à la place de BusyBox).

```dockerfile
FROM alpine:latest

RUN apk add --no-cache python3 shadow

CMD ["sleep", "infinity"]

```

#### B. `docker-compose.yml`

Déploie les 3 machines cibles (`alpine1`, `alpine2`, `alpine3`) sans exposer de ports SSH.

```yaml
services:
  alpine1:
    build: .
    container_name: alpine1

  alpine2:
    build: .
    container_name: alpine2

  alpine3:
    build: .
    container_name: alpine3

```

#### C. `ansible.cfg`

Définit l'inventaire par défaut et redirige le dossier temporaire distant vers `/tmp/.ansible/tmp` pour éviter tout problème de permissions sur Alpine.

```ini
[defaults]
inventory = ./inventory.ini
host_key_checking = False
remote_tmp = /tmp/.ansible/tmp

```

#### D. `inventory.ini`

Déclare les 3 conteneurs avec le connecteur `docker` natif et l'utilisateur `root`.

```ini
[alpines]
alpine1 ansible_connection=docker ansible_user=root
alpine2 ansible_connection=docker ansible_user=root
alpine3 ansible_connection=docker ansible_user=root

```

---

### 4. Démarrer l'infrastructure et valider Ansible

1. **Construire l'image et lancer les 3 conteneurs**
```bash
docker compose up -d --build

```


*Vérification :* `docker ps` affiche `alpine1`, `alpine2` et `alpine3` avec le statut `Up`.
2. **Tester la connectivité Ansible**
```bash
ansible alpines -m ping

```


*Vérification :* Les trois conteneurs répondent `"ping": "pong"` en vert.

---

### 5. Premier Playbook : Création simple d'utilisateurs (`create_users.yml`)

Crée le fichier `create_users.yml` à la racine du dossier pour ajouter deux utilisateurs sur les 3 machines :

```yaml
---
- name: Exemple simple de playbook avec variable
  hosts: localhost
  vars:
    message: "Bonjour, Ansible!"
  tasks:
    - name: Afficher le message
      debug:
        msg: "{{ message }}"
```

1. **Exécuter le playbook**
```bash
ansible-playbook variable_playbook.yml

```



### 6. Commandes utiles pour gérer le lab

| Action | Commande |
| --- | --- |
| **Arrêter les conteneurs** (en conservant l'état) | `docker compose stop` |
| **Redémarrer les conteneurs** | `docker compose start` |
| **Remettre les 3 machines à zéro** (état vierge) | `docker compose down && docker compose up -d` |
| **Ouvrir un shell dans un conteneur** | `docker exec -it alpine1 sh` |

---

Veux-tu que je génère ce tutoriel en fichier Markdown (`.md`) ou PDF prêt à être partagé avec tes étudiants ?