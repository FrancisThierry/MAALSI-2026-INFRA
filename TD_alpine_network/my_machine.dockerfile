FROM alpine:latest

# Mettre à jour les paquets et installer curl
RUN apk update && apk add --no-cache curl

# Définir le répertoire de travail par défaut
WORKDIR /app

# Commande exécutée par défaut au lancement du conteneur
CMD ["sh"]