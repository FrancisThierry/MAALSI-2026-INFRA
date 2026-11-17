Voici l'essentiel d'Ansible, condensé et prêt à l'emploi.

---

### 1. La syntaxe d'un Playbook

Un playbook est un fichier **YAML** structuré par indentation (2 espaces, jamais de tabulations).

```yaml
---
- name: Déploiement serveur web       # Nom du scénario (Play)
  hosts: webservers                   # Groupe cible (défini dans l'inventaire)
  become: true                        # Exécution en sudo (root)
  vars:                               # Déclaration des variables
    port_http: 80

  tasks:                              # Liste des actions à exécuter
    - name: Installer Nginx
      ansible.builtin.apt:            # Nom du module (FQCN)
        name: nginx
        state: present
      notify: Redémarrer Nginx        # Déclenche un handler si modifié

  handlers:                           # Tâches déclenchées uniquement sur changement
    - name: Redémarrer Nginx
      ansible.builtin.service:
        name: nginx
        state: restarted

```

---

### 2. Les Variables

On les appelle avec `{{ nom_variable }}`. Si une valeur commence par `{{`, il faut mettre des guillemets autour.

```yaml
vars:
  chaine: "bonjour"
  liste:
    - nginx
    - git
  dictionnaire:
    nom: app
    port: 8080

tasks:
  - name: Exemple d'utilisation
    ansible.builtin.debug:
      msg: "App {{ dictionnaire.nom }} sur le port {{ dictionnaire['port'] }}"

```

* **Variables système (*Facts*) :** `ansible_facts['os_family']`, `ansible_facts['default_ipv4']['address']`, `inventory_hostname`.
* **Capture de résultat :** `register: resultat` stocke la sortie d'une tâche pour la réutiliser plus tard (`resultat.stdout`, `resultat.rc`).
* **Création dynamique :** `ansible.builtin.set_fact: ma_var="valeur"`.

---

### 3. Les Conditions (`when`)

Le mot-clé `when` évalue une expression **sans** les accolades `{{ }}`. Une liste de conditions agit comme un `ET` logique.

```yaml
- name: Installer uniquement sur Debian avec plus de 2 Go de RAM
  ansible.builtin.apt:
    name: htop
    state: present
  when:
    - ansible_facts['os_family'] == "Debian"
    - ansible_facts['memtotal_mb'] > 2048
    - variable_optionnelle is defined

```

---

### 4. Les Boucles (`loop`)

Le mot-clé `loop` parcourt une **liste**. L'élément courant s'appelle `item`.

```yaml
# Boucle simple
- name: Installer des paquets
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  loop:
    - curl
    - vim
    - git

# Boucle sur objets
- name: Créer des dossiers
  ansible.builtin.file:
    path: "{{ item.chemin }}"
    mode: "{{ item.droits }}"
    state: directory
  loop:
    - { chemin: "/var/www", droits: "0755" }
    - { chemin: "/var/log/app", droits: "0750" }

```

---

### 5. Fichiers, Dossiers et Permissions

Trois modules principaux couvrent 90 % des besoins. Les permissions (`mode`) s'écrivent toujours entre guillemets (`"0644"`).

* **Créer un dossier / modifier des droits (`file`) :**
```yaml
- name: Créer un répertoire avec permissions
  ansible.builtin.file:
    path: /opt/mon_app
    state: directory          # directory | file | absent | touch | link
    owner: www-data
    group: www-data
    mode: "0755"
    recurse: true             # Applique récursivement (optionnel)

```


* **Copier un fichier brut (`copy`) :**
```yaml
- name: Copier un script
  ansible.builtin.copy:
    src: files/script.sh
    dest: /usr/local/bin/script.sh
    owner: root
    mode: "0750"

```


* **Modifier une ligne dans un fichier (`lineinfile`) :**
```yaml
- name: Désactiver le login root SSH
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    regexp: "^PermitRootLogin"
    line: "PermitRootLogin no"

```



---

### 6. Les Utilisateurs et Groupes

* **Créer un groupe (`group`) :**
```yaml
- name: Créer le groupe deploy
  ansible.builtin.group:
    name: deploy
    state: present

```


* **Créer un utilisateur (`user`) :**
```yaml
- name: Créer l'utilisateur deploy
  ansible.builtin.user:
    name: deploy
    groups: deploy,sudo
    append: true              # Ajoute aux groupes existants sans les écraser
    shell: /bin/bash
    create_home: true
    state: present            # present | absent

```


* **Déployer une clé SSH (`authorized_key`) :**
```yaml
- name: Ajouter la clé publique SSH
  ansible.posix.authorized_key:
    user: deploy
    key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"

```



---

### 7. Jinja2 (Templates et Filtres)

Jinja2 permet de générer des fichiers de configuration dynamiques (`.j2`) via le module `template`, ou de transformer des variables à la volée.

**Dans un playbook (Module + Filtres) :**

```yaml
- name: Générer la config Nginx
  ansible.builtin.template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/sites-available/app.conf
    mode: "0644"

# Exemples de filtres utiles dans les playbooks :
# {{ ma_var | default('valeur_par_defaut') }}
# {{ liste_ips | join(',') }}
# {{ mot_de_passe | password_hash('sha512') }}

```

**Dans le fichier template (`templates/nginx.conf.j2`) :**

```jinja2
server {
    listen {{ port_http | default(80) }};
    server_name {{ inventory_hostname }};

    {% if activer_ssl %}
    listen 443 ssl;
    {% endif %}

    {% for backend in serveurs_backend %}
    # Backend : {{ backend }}
    {% endfor %}
}

```

Un **FQCN** (*Fully Qualified Collection Name*, ou « nom de collection pleinement qualifié ») est le chemin complet permettant d'identifier de manière unique un module, un plugin ou un rôle dans Ansible.

Il est toujours composé de **trois parties** séparées par des points :
`espace_de_noms.nom_de_la_collection.nom_du_module`

### Exemples concrets

* `ansible.builtin.copy` : le module `copy`, situé dans la collection `builtin` (les modules de base), maintenue par `ansible`.
* `ansible.posix.authorized_key` : le module `authorized_key`, situé dans la collection `posix`, maintenue par `ansible`.
* `community.docker.docker_container` : le module `docker_container`, situé dans la collection `docker`, maintenue par la `community`.

### Pourquoi l'utiliser à la place du nom court (`copy` ou `apt`) ?

Depuis Ansible 2.10, les milliers de modules existants ont été sortis du cœur d'Ansible pour être rangés dans des **collections** indépendantes. Utiliser le FQCN est devenu la bonne pratique officielle pour deux raisons :

1. **Éviter les conflits de noms :** Deux collections différentes peuvent contenir un module portant le même nom (par exemple `user` pour un système Linux vs `user` pour une application métier). Le FQCN lève toute ambiguïté.
2. **Performance et clarté :** Ansible sait exactement où chercher le code Python du module sans avoir à parcourir toute son arborescence, et la lecture du playbook indique immédiatement de quelle dépendance provient chaque action.

Ansible compte plusieurs milliers de modules répartis dans différentes collections. On distingue les **modules intégrés (`ansible.builtin`)**, toujours disponibles par défaut, et les **collections externes** (à installer via `ansible-galaxy collection install`).

Voici les modules essentiels classés par usage.

---

### 1. Modules intégrés (`ansible.builtin.*`)

#### Fichiers et Arborescence

* **`copy`** : Copie un fichier depuis le contrôleur vers le serveur cible.
* **`template`** : Génère un fichier sur la cible à partir d'un modèle Jinja2 (`.j2`) en remplaçant les variables.
* **`file`** : Crée/supprime des dossiers, des fichiers vides, des liens symboliques et gère les permissions (`mode`, `owner`, `group`).
* **`lineinfile`** : Ajoute, modifie ou supprime une ligne unique dans un fichier via une expression régulière.
* **`blockinfile`** : Insère ou met à jour un bloc complet de plusieurs lignes encadré par des balises commentaires.
* **`fetch`** : Télécharge un fichier depuis le serveur cible vers le contrôleur (l'inverse de `copy`).
* **`stat`** : Récupère les informations d'un fichier ou dossier (existence, taille, droits, checksum) pour les tester dans un `when`.
* **`find`** : Recherche des fichiers selon des critères (nom, âge, taille) pour agir dessus ensuite.
* **`unarchive`** : Décompresse une archive (`.tar.gz`, `.zip`) sur la cible.
* **`assemble`** : Fusionne plusieurs fragments de fichiers en un seul fichier de configuration.

#### Paquets et Services

* **`package`** : Installe/supprime un paquet en détectant automatiquement le gestionnaire de l'OS (`apt`, `dnf`, `yum`, etc.).
* **`apt`** / **`dnf`** / **`yum`** : Gestion fine des paquets (mise à jour du cache, `upgrade`, suppression des dépendances inutiles).
* **`service`** : Démarre, arrête ou redémarre un service de manière générique.
* **`systemd`** : Gestion complète des unités Systemd (`state`, `enabled`, `daemon_reload`).
* **`pip`** : Installe des bibliothèques Python.

#### Exécution de commandes

* **`command`** : Exécute une commande directement sans passer par un shell (sécurisé, mais n'accepte ni `|`, ni `>`, ni variables d'environnement `$VAR`).
* **`shell`** : Exécute une commande via `/bin/sh` (autorise les pipes, redirections et scripts complexes).
* **`script`** : Transfère un script local (Bash, Python...) sur la cible et l'exécute.
* **`raw`** : Exécute une commande SSH brute sans nécessiter Python sur la machine cible (utile pour initialiser des routeurs ou des serveurs vierges).

#### Utilisateurs et Système

* **`user`** / **`group`** : Création, modification et suppression des comptes utilisateurs et des groupes locaux.
* **`cron`** : Gestion des tâches planifiées dans la crontab.
* **`hostname`** : Définit le nom d'hôte de la machine.
* **`reboot`** : Redémarre la machine et attend qu'elle redevienne accessible en SSH.
* **`setup`** : Collecte les informations matérielles et logicielles de la machine (*Facts*).

#### Réseau et Web

* **`uri`** : Effectue des requêtes HTTP/HTTPS (idéal pour interagir avec des APIs REST, envoyer du JSON, vérifier un code statut).
* **`get_url`** : Télécharge un fichier depuis une URL HTTP, HTTPS ou FTP directement vers la cible.
* **`wait_for`** : Met le playbook en pause jusqu'à ce qu'un port réseau s'ouvre, se ferme, ou qu'un fichier/texte apparaisse.

#### Contrôle du Playbook et Logique

* **`debug`** : Affiche un message ou le contenu d'une variable dans le terminal.
* **`set_fact`** : Crée ou modifie une variable dynamiquement pendant l'exécution.
* **`assert`** : Vérifie qu'une condition est vraie et fait échouer le playbook sinon (tests unitaires d'infrastructure).
* **`fail`** : Interrompt volontairement l'exécution avec un message d'erreur personnalisé.
* **`pause`** : Suspend l'exécution pendant une durée donnée ou attend un appui sur `Entrée`.
* **`include_tasks`** / **`import_tasks`** : Découpe un gros playbook en plusieurs sous-fichiers YAML.
* **`include_role`** / **`import_role`** : Appelle un rôle réutilisable.

---

### 2. Collections externes les plus courantes

Pour tout ce qui sort du système Linux de base, on utilise les collections officielles ou communautaires :

* **`ansible.posix`** (Administration Linux avancée) :
* `authorized_key` : Déploie les clés publiques SSH.
* `firewalld` : Configure le pare-feu Firewalld.
* `mount` : Gère les points de montage et le fichier `/etc/fstab`.
* `synchronize` : Encapsule `rsync` pour des transferts rapides.
* `sysctl` : Modifie les paramètres du noyau Linux.


* **`community.general`** (Boîte à outils universelle) :
* `ufw` : Configure le pare-feu UFW (Ubuntu/Debian).
* `git_config`, `npm`, `composer`, `snap`, `timezone`, `locales`.
* `archive` : Crée des archives `.zip` ou `.tar.gz`.


* **`community.docker`** :
* `docker_container`, `docker_image`, `docker_compose_v2`, `docker_network`.


* **`kubernetes.core`** :
* `k8s` : Applique des manifestes Kubernetes (Pods, Deployments, Services).


* **`community.postgresql` / `community.mysql**` :
* `postgresql_db`, `postgresql_user`, `mysql_db`, `mysql_user`.


* **`ansible.windows`** :
* `win_copy`, `win_service`, `win_package`, `win_powershell`, `win_feature`.



---

### Comment lister et consulter la doc depuis le terminal ?

La documentation complète de tous les modules installés est embarquée directement dans Ansible via la commande `ansible-doc` :

```bash
# Lister tous les modules disponibles sur votre machine
ansible-doc -l

# Afficher la documentation et les exemples d'un module précis
ansible-doc ansible.builtin.lineinfile

```