### Étape 1 : Installer une distribution Ubuntu sous WSL (depuis Windows)

Si votre poste Windows ne dispose pas encore de distribution Linux active, l'installation se fait directement depuis le terminal Windows (PowerShell ou Invite de commandes) :

1. Ouvrez **PowerShell** en tant qu'administrateur.
2. Installez WSL et la distribution Ubuntu par défaut avec la commande unique :
```powershell
wsl --install -d Ubuntu

```


3. Redémarrez votre ordinateur si Windows le demande.
4. Au redémarrage, une fenêtre de terminal s'ouvre automatiquement pour vous demander de **créer un nom d'utilisateur et un mot de passe** pour votre nouvel environnement Linux.

*Vérification :* Ouvrez votre terminal (ou Windows Terminal) et lancez `wsl -l -v` pour vous assurer qu'Ubuntu s'exécute bien en version 2.

---

### Étape 2 : Préparer l'environnement système (depuis Ubuntu / WSL)

Ouvrez votre terminal Ubuntu (WSL) et mettez à jour les paquets pour installer les outils indispensables au développement et à Python :

```bash
# Mettre à jour le catalogue des paquets
sudo apt update && sudo apt upgrade -y

# Installer Python 3, le gestionnaire pip et l'outil de création d'environnements virtuels
sudo apt install -y python3-pip python3-venv python3-full sshpass git

```

---

### Étape 3 : Isoler et installer Ansible

Pour respecter les standards de sécurité des distributions Linux modernes (qui bloquent l'installation globale de paquets via `pip`), nous allons configurer Ansible dans un environnement virtuel (`venv`).

```bash
# 1. Créer un dossier de travail dédié à vos projets d'automatisation
mkdir -p ~/ansible-workspace && cd ~/ansible-workspace

# 2. Créer l'environnement virtuel Python
python3 -m venv .venv

# 3. Activer l'environnement virtuel
source .venv/bin/activate

```

*(Votre invite de commande doit maintenant afficher `(.venv)` au début de la ligne).*

```bash
# 4. Mettre à jour pip à l'intérieur de l'environnement virtuel
pip install --upgrade pip

# 5. Installer Ansible
pip install ansible

```

---

### Étape 4 : Valider l'installation

Toujours avec l'environnement virtuel activé, vérifiez que l'outil de contrôle est opérationnel :

```bash
ansible --version

```

*Le terminal doit afficher la version d'Ansible ainsi que le chemin de l'interpréteur Python associé.*

Pour effectuer un premier test d'exécution local (*Ad-Hoc*), lancez la commande de ping Ansible sur votre machine locale :

```bash
ansible localhost -m ping -c local

```

*Si l'installation est réussie, vous obtiendrez un retour JSON avec le statut `"pong": true`.*