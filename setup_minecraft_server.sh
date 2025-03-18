#!/bin/bash

# Mettre à jour le système et installer les dépendances
echo "Mise à jour du système et installation des dépendances..."
sudo apt update && sudo apt upgrade -y
sudo apt install openjdk-17-jdk screen wget -y

# Créer un répertoire pour le serveur Minecraft
echo "Création du répertoire pour le serveur Minecraft..."
mkdir -p ~/minecraft-server
cd ~/minecraft-server

# Télécharger le serveur Minecraft Vanilla 1.21.4
echo "Téléchargement du serveur Minecraft Vanilla 1.21.4..."
wget https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar -O minecraft_server.jar

# Accepter l'EULA
echo "Acceptation de l'EULA..."
echo "eula=true" > eula.txt

# Créer un script pour gérer le serveur Minecraft
echo "Création du script de gestion du serveur Minecraft..."
cat << 'EOF' > ~/minecraft-server/manage_server.sh
#!/bin/bash

SCREEN_NAME="minecraft-server"
SERVER_JAR="minecraft_server.jar"
MIN_RAM=2G
MAX_RAM=8G

start_server() {
    if screen -list | grep -q "\.$SCREEN_NAME"; then
        echo "Le serveur est déjà en cours d'exécution."
    else
        echo "Démarrage du serveur Minecraft..."
        screen -dmS $SCREEN_NAME java -Xmx$MAX_RAM -Xms$MIN_RAM -jar $SERVER_JAR nogui
        echo "Serveur démarré dans un screen nommé $SCREEN_NAME."
    fi
}

stop_server() {
    if screen -list | grep -q "\.$SCREEN_NAME"; then
        echo "Arrêt du serveur Minecraft..."
        screen -S $SCREEN_NAME -X stuff "stop^M"
        echo "Serveur arrêté."
    else
        echo "Le serveur n'est pas en cours d'exécution."
    fi
}

check_server() {
    if screen -list | grep -q "\.$SCREEN_NAME"; then
        echo "Le serveur Minecraft est en ligne."
    else
        echo "Le serveur Minecraft est hors ligne."
    fi
}

# Vérifie si un argument est passé et exécute la fonction correspondante
if [ "$1" == "start_server" ]; then
    start_server
elif [ "$1" == "stop_server" ]; then
    stop_server
elif [ "$1" == "check_server" ]; then
    check_server
else
    echo "Bienvenue sur votre serveur Minecraft!"
    echo "Pour démarrer le serveur, utilisez : ./manage_server.sh start_server"
    echo "Pour arrêter le serveur, utilisez : ./manage_server.sh stop_server"
    echo "Pour vérifier l'état du serveur, utilisez : ./manage_server.sh check_server"
    echo "Pour accéder au menu screen, utilisez : screen -r $SCREEN_NAME"
fi
EOF

# Rendre le script exécutable
chmod +x ~/minecraft-server/manage_server.sh

echo "Installation et configuration terminées. Vous pouvez maintenant utiliser le script manage_server.sh pour gérer votre serveur Minecraft."
