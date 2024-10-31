#!/bin/bash

# Colors per als missatges

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

NC='\033[0m' # Sense color

# Trap per ignorar Ctrl+C

trap '' SIGINT

# Directori i fitxer de logs

LOG_DIR="logs"

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')

LOG_FILE="$LOG_DIR/gestor_aplicacions_$TIMESTAMP.log"

# Crear el directori de logs si no existeix

if [ ! -d "$LOG_DIR" ]; then

    mkdir -p "$LOG_DIR"

fi

# Funció per registrar en el log

log_message() {

    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"

}

# Funció per mostrar missatges d'error

error_message() {

    echo -e "${RED}[ERROR]${NC} $1"

    log_message "[ERROR] $1"

}

# Funció per mostrar missatges d'èxit

success_message() {

    echo -e "${GREEN}[ÈXIT]${NC} $1"

    log_message "[ÈXIT] $1"

}

# Funció per comprovar privilegis d'administrador 

check_sudo() {

    if [ "$EUID" -ne 0 ]; then

        error_message "Aquest script requereix privilegis d'administrador. Executeu com a root."

        exit 1

    fi

}

# Funció per instal·lar un programa

instal·lar() {

    echo "Introduïu el nom del programa a instal·lar:"

    read programa

    if sudo apt-get install -y "$programa"; then

        success_message "Programa $programa instal·lat correctament."

    else

        error_message "Error en instal·lar el programa $programa."

    fi

}

# Funció per eliminar un programa

eliminar() {

    echo "Introduïu el nom del programa a eliminar:"

    read programa

    if sudo apt-get remove -y "$programa"; then

        success_message "Programa $programa eliminat correctament."

    else

        error_message "Error en eliminar el programa $programa."

    fi

}

# Funció per actualitzar programes

actualitzar() {

    if sudo apt-get update && sudo apt-get upgrade -y; then

        success_message "Actualització completada correctament."

    else

        error_message "Error en actualitzar els programes."

    fi

}

# Funció per gestionar perfils de servidor

gestionar_perfil() {

    check_sudo

    echo "Selecciona el perfil de servidor (web/db/mail):"

    read perfil

    case "$perfil" in

        web)

            configurar_servidor_web

            ;;

        db)

            configurar_servidor_db

            ;;

        mail)

            configurar_servidor_mail

            ;;

        *)

            error_message "Perfil no reconegut."

            ;;

    esac

}

# Funció per configurar servidor web

configurar_servidor_web() {

    log_message "Configurant perfil de servidor web..."

    echo "Configurant perfil de servidor web..."

    apt-get update

    apt-get install -y apache2

    echo "<VirtualHost *:80>

    DocumentRoot /var/www/html

    </VirtualHost>" > /etc/apache2/sites-available/000-default.conf

    if systemctl restart apache2; then

        success_message "Servidor web configurat."

    else

        error_message "Error en configurar el servidor web."

    fi

}

# Funció per configurar servidor de bases de dades

configurar_servidor_db() {

    log_message "Configurant perfil de servidor de bases de dades..."

    echo "Configurant perfil de servidor de bases de dades..."

    apt-get update

    apt-get install -y mysql-server

    if systemctl start mysql && systemctl enable mysql; then

        success_message "Servidor de bases de dades configurat."

    else

        error_message "Error en configurar el servidor de bases de dades."

    fi

}

# Funció per configurar servidor de correu

configurar_servidor_mail() {

    log_message "Configurant perfil de servidor de correu..."

    echo "Configurant perfil de servidor de correu..."

    apt-get update

    apt-get install -y postfix

    if systemctl start postfix && systemctl enable postfix; then

        success_message "Servidor de correu configurat."

    else

        error_message "Error en configurar el servidor de correu."

    fi

}

# Funció per llistar aplicacions instal·lades

llistar_aplicacions() {

    echo -e "${YELLOW}Aplicacions instal·lades:${NC}"

    log_message "Llistant aplicacions instal·lades."

    dpkg --list | less

}

# Funció per pausar un procés

pausar_proces() {

    echo "Introduïu el PID del procés a pausar:"

    read pid

    if sudo kill -STOP "$pid"; then

        success_message "Procés $pid pausat correctament."

    else

        error_message "Error en pausar el procés $pid."

    fi

}

# Funció per canviar la prioritat d'un procés

canviar_prioritat() {

    echo "Introduïu el PID del procés:"

    read pid

    echo "Introduïu la nova prioritat (-20 a 19):"

    read prioritat

    if sudo renice "$prioritat" -p "$pid"; then

        success_message "Prioritat del procés $pid canviada a $prioritat."

    else

        error_message "Error en canviar la prioritat del procés $pid."

    fi

}

# Menú principal

while true; do

    echo -e "\n${YELLOW}Menú de Gestió d'Aplicacions:${NC}"

    echo "1. Instal·lar un programa"

    echo "2. Eliminar un programa"

    echo "3. Actualitzar programes"

    echo "4. Gestionar perfils de servidor"

    echo "5. Llistar aplicacions instal·lades"

    echo "6. Pausar un procés"

    echo "7. Canviar la prioritat d'un procés"

    echo "8. Sortir"

    read -p "Seleccioneu una opció: " opcio

    case "$opcio" in

        1) log_message "Seleccionada opció: Instal·lar un programa"; instal·lar ;;

        2) log_message "Seleccionada opció: Eliminar un programa"; eliminar ;;

        3) log_message "Seleccionada opció: Actualitzar programes"; actualitzar ;;

        4) log_message "Seleccionada opció: Gestionar perfils de servidor"; gestionar_perfil ;;

        5) log_message "Seleccionada opció: Llistar aplicacions instal·lades"; llistar_aplicacions ;;

        6) log_message "Seleccionada opció: Pausar un procés"; pausar_proces ;;

        7) log_message "Seleccionada opció: Canviar la prioritat d'un procés"; canviar_prioritat ;;

        8) log_message "Seleccionada opció: Sortir"; echo "Sortint..."; exit 0 ;;

        *) error_message "Opció no vàlida. Intenteu de nou." ;;

    esac

done
