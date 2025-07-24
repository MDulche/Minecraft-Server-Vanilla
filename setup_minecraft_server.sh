#!/bin/bash
set -e

# 1. Installation des dépendances minimales
sudo apt update && sudo apt install -y openjdk-17-jre-headless screen wget unzip

# 2. Création du dossier serveur
mkdir -p ~/minecraft-server
cd ~/minecraft-server

# 3. Téléchargement du serveur Vanilla (1.21.4)
wget -O server.jar "https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar"

# 4. Acceptation automatique de la EULA
echo "eula=true" > eula.txt

# 5. Création du script manage_server.sh
cat > manage_server.sh <<'EOF'
#!/bin/bash

MIN_RAM="2G"
MAX_RAM="8G"
SCREEN_NAME="minecraft-server"

start_server() {
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "Serveur déjà démarré !"
    else
        screen -dmS "$SCREEN_NAME" java -Xms$MIN_RAM -Xmx$MAX_RAM -jar server.jar nogui
        echo "Serveur démarré dans le screen $SCREEN_NAME"
    fi
}

stop_server() {
    if screen -list | grep -q "$SCREEN_NAME"; then
        screen -S "$SCREEN_NAME" -p 0 -X stuff "stop$(printf \\r)"
        sleep 10
        screen -S "$SCREEN_NAME" -X quit
        echo "Serveur arrêté."
    else
        echo "Pas de serveur en cours."
    fi
}

check_server() {
    if screen -list | grep -q "$SCREEN_NAME"; then
        echo "Serveur en ligne."
    else
        echo "Serveur arrêté."
    fi
}

case "$1" in
    start_server) start_server ;;
    stop_server) stop_server ;;
    check_server) check_server ;;
    *) echo "Usage: $0 {start_server|stop_server|check_server}" ;;
esac
EOF

chmod +x manage_server.sh

echo
echo "Serveur installé dans ~/minecraft-server/"
echo "Gestion (depuis ce dossier) :"
echo "  ./manage_server.sh start_server   # Démarrer"
echo "  ./manage_server.sh stop_server    # Arrêter"
echo "  ./manage_server.sh check_server   # État"
echo
