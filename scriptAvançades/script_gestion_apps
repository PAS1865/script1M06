#!/bin/bash



# Colores para los mensajes

RED='\033[0;31m'

GREEN='\033[0;32m'

YELLOW='\033[1;33m'

NC='\033[0m' # Sin color



# Trap para ignorar Ctrl+C

trap '' SIGINT



# Directorio y archivo de logs

LOG_DIR="logs"

TIMESTAMP=$(date +'%Y%m%d_%H%M%S')

LOG_FILE="$LOG_DIR/gestor_aplicaciones_$TIMESTAMP.log"



# Crear el directorio de logs si no existe

if [ ! -d "$LOG_DIR" ]; then

    mkdir -p "$LOG_DIR"

fi



# Función para registrar en el log

log_message() {

    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"

}



# Función para mostrar mensajes de error

error_message() {

    echo -e "${RED}[ERROR]${NC} $1"

    log_message "[ERROR] $1"

}



# Función para mostrar mensajes de éxito

success_message() {

    echo -e "${GREEN}[ÉXITO]${NC} $1"

    log_message "[ÉXITO] $1"

}



# Función para instalar un programa

instalar() {

    echo "Introduzca el nombre del programa a instalar:"

    read programa

    if sudo apt-get install -y "$programa"; then

        success_message "Programa $programa instalado correctamente."

    else

        error_message "Fallo al instalar el programa $programa."

    fi

}



# Función para eliminar un programa

eliminar() {

    echo "Introduzca el nombre del programa a eliminar:"

    read programa

    if sudo apt-get remove -y "$programa"; then

        success_message "Programa $programa eliminado correctamente."

    else

        error_message "Fallo al eliminar el programa $programa."

    fi

}



# Función para actualizar programas

actualizar() {

    if sudo apt-get update && sudo apt-get upgrade -y; then

        success_message "Actualización completada correctamente."

    else

        error_message "Fallo al actualizar los programas."

    fi

}



# Función para gestionar perfiles de servidor

gestionar_perfil() {

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

            error_message "Perfil no reconocido."

            ;;

    esac

}



# Función para configurar servidor web

configurar_servidor_web() {

    log_message "Configurando perfil de servidor web..."

    echo "Configurando perfil de servidor web..."

    apt-get update

    apt-get install -y apache2

    echo "<VirtualHost *:80>

    DocumentRoot /var/www/html

    </VirtualHost>" > /etc/apache2/sites-available/000-default.conf

    if systemctl restart apache2; then

        success_message "Servidor web configurado."

    else

        error_message "Fallo al configurar el servidor web."

    fi

}



# Función para configurar servidor de bases de datos

configurar_servidor_db() {

    log_message "Configurando perfil de servidor de bases de datos..."

    echo "Configurando perfil de servidor de bases de datos..."

    apt-get update

    apt-get install -y mysql-server

    if systemctl start mysql && systemctl enable mysql; then

        success_message "Servidor de bases de datos configurado."

    else

        error_message "Fallo al configurar el servidor de bases de datos."

    fi

}



# Función para configurar servidor de correo

configurar_servidor_mail() {

    log_message "Configurando perfil de servidor de correo..."

    echo "Configurando perfil de servidor de correo..."

    apt-get update

    apt-get install -y postfix

    if systemctl start postfix && systemctl enable postfix; then

        success_message "Servidor de correo configurado."

    else

        error_message "Fallo al configurar el servidor de correo."

    fi

}



# Función para listar aplicaciones instaladas

listar_aplicaciones() {

    echo -e "${YELLOW}Aplicaciones instaladas:${NC}"

    log_message "Listando aplicaciones instaladas."

    dpkg --list | less

}



# Función para pausar un proceso

pausar_proces() {

    echo "Introduzca el PID del proceso a pausar:"

    read pid

    if sudo kill -STOP "$pid"; then

        success_message "Proceso $pid pausado correctamente."

    else

        error_message "Fallo al pausar el proceso $pid."

    fi

}



# Función para cambiar la prioridad de un proceso

cambiar_prioridad() {

    echo "Introduzca el PID del proceso:"

    read pid

    echo "Introduzca la nueva prioridad (-20 a 19):"

    read prioridad

    if sudo renice "$prioridad" -p "$pid"; then

        success_message "Prioridad del proceso $pid cambiada a $prioridad."

    else

        error_message "Fallo al cambiar la prioridad del proceso $pid."

    fi

}



# Menú principal

while true; do

    echo -e "\n${YELLOW}Menú de Gestión de Aplicaciones:${NC}"

    echo "1. Instalar un programa"

    echo "2. Eliminar un programa"

    echo "3. Actualizar programas"

    echo "4. Gestionar perfiles de servidor"

    echo "5. Listar aplicaciones instaladas"

    echo "6. Pausar un proceso"

    echo "7. Cambiar la prioridad de un proceso"

    echo "8. Salir"

    

    read -p "Seleccione una opción: " opcion



    case "$opcion" in

        1) log_message "Seleccionada opción: Instalar un programa"; instalar ;;

        2) log_message "Seleccionada opción: Eliminar un programa"; eliminar ;;

        3) log_message "Seleccionada opción: Actualizar programas"; actualizar ;;

        4) log_message "Seleccionada opción: Gestionar perfiles de servidor"; gestionar_perfil ;;

        5) log_message "Seleccionada opción: Listar aplicaciones instaladas"; listar_aplicaciones ;;

        6) log_message "Seleccionada opción: Pausar un proceso"; pausar_proces ;;

        7) log_message "Seleccionada opción: Cambiar la prioridad de un proceso"; cambiar_prioridad ;;

        8) log_message "Seleccionada opción: Salir"; echo "Saliendo..."; exit 0 ;;

        *) error_message "Opción no válida. Intente de nuevo." ;;

    esac

done
