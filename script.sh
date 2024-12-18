#!/bin/bash

logfile="log.txt" # Nombre del archivo de registro
userfile="usuario.txt" # Archivo que contiene los usuarios y contraseñas
# Función para asegurarse de que el archivo de log exista
borrar_txt_logs() {
    # Verifica si la carpeta logs existe
    if [ -d "logs" ]; then
        # Elimina los archivos .txt dentro de la carpeta logs
        rm logs/*.txt
        echo "Archivos .txt eliminados de la carpeta logs."
    else
        echo "La carpeta logs no existe."
    fi
}

crear_usuario() {
    echo "Creando usuarios..." >> "$logfile"

    # Leer usuarios y contraseñas desde el archivo, asumiendo el formato "usuario:contraseña"
    while IFS=: read -r username password; do
        if [ -z "$username" ] || [ -z "$password" ]; then
            echo "Formato incorrecto en el archivo de usuarios." >> "$logfile"
            echo "Formato incorrecto en el archivo de usuarios."
            continue
        fi

        # Comprobar si el usuario ya existe
        if id "$username" &>/dev/null; then
            echo "El usuario $username ya existe." >> "$logfile"
            echo "El usuario $username ya existe."
        else
            # Crear el usuario y establecer la contraseña
            if useradd "$username" >> "$logfile" 2>&1; then
                echo "$username:$password" | chpasswd
                echo "Usuario $username creado con éxito." >> "$logfile"
                echo "Usuario $username creado con éxito."
            else
                echo "Error al crear el usuario $username." >> "$logfile"
                echo "Error al crear el usuario $username."
            fi
        fi
    done < "$userfile"

    echo "Proceso de creación de usuarios finalizado."
    echo
}

modificar_red() {
    # Definir la carpeta y el archivo de log
    logdir="$(dirname "$0")/logs"
    mkdir -p "$logdir"
    logfile="$logdir/$(date +'%Y-%m-%d_%H-%M-%S').txt"

    # Listar interfaces de red disponibles
    echo "Interfaces de red disponibles:"
    ip link show | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2}'

    # Solicitar la configuración de red al usuario
    read -p "Introduce el nombre de la interfaz de red: " INTERFACE  
    read -p "Introduce la dirección IP: " IP_ADDRESS 
    read -p "Introduce la máscara de red (CIDR, por ejemplo, 24): " NETMASK
    read -p "Introduce la puerta de enlace: " GATEWAY
    read -p "Introduce el DNS: " DNS

    # Registrar la configuración solicitada
    echo "$(date): Configuración solicitada - Interfaz: $INTERFACE, IP: $IP_ADDRESS, Máscara: $NETMASK, Puerta de enlace: $GATEWAY, DNS: $DNS" >> "$logfile"

    # Configurar la interfaz de red temporalmente
    sudo ip addr flush dev $INTERFACE
    sudo ip addr add $IP_ADDRESS/$NETMASK dev $INTERFACE
    sudo ip link set $INTERFACE up
    sudo ip route add default via $GATEWAY

    # Registrar la configuración temporal aplicada
    echo "$(date): Configuración temporal aplicada a la interfaz $INTERFACE" >> "$logfile"

    # Configurar DNS temporalmente
    echo "nameserver $DNS" | sudo tee /etc/resolv.conf > /dev/null

    # Hacer que la configuración sea persistente en /etc/network/interfaces
    sudo tee /etc/network/interfaces.d/$INTERFACE.cfg > /dev/null <<EOT
auto $INTERFACE
iface $INTERFACE inet static
    address $IP_ADDRESS
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS
EOT

    # Reiniciar la interfaz de red para aplicar la configuración persistente
    sudo ifdown $INTERFACE && sudo ifup $INTERFACE

    # Registrar la configuración persistente aplicada
    echo "$(date): Configuración persistente aplicada y guardada para la interfaz $INTERFACE" >> "$logfile"

    echo "Configuración de red aplicada y guardada."
}



while true; do
    clear
    echo "----------------------------------------------------------------------"
    echo "$(date '+%Y-%m-%d') | $(date '+%H:%M:%S')"
    echo "----------------------------------------------------------------------"
    echo " 1    Crear copia de seguridad"
    echo " 2    Crear usuario"
    echo " 3    Modificar tarjeta de red (Ejecutar con administrador)"
    echo " 4    Borrar archivos del log generados"
    echo " 5    Salir"
    echo "----------------------------------------------------------------------"
    echo

    # Solicitar opción si 'var' no ha sido establecida
    if [ -z "$var" ]; then
        read -p "Seleccione una opción [1-5]: " var
    fi

    case "$var" in
        1) 
            echo "Opción 1: Crear copia de seguridad"
            #!/bin/bash

# Crear un timestamp para el archivo ZIP y log (formato YYYYMMDD-HHMMSS)
timestamp=$(date +"%Y%m%d-%H%M%S")

# Definir la carpeta de logs y crearla si no existe
log_dir="$(dirname "$0")/logs"
if [ ! -d "$log_dir" ]; then
    mkdir -p "$log_dir"
fi

# Definir el nombre del archivo de log en el directorio logs
log_file="$log_dir/log_backup_$timestamp.txt"

# Definir el nombre del archivo ZIP
zip_file="backup_$timestamp.zip"

# Definir la carpeta temporal para la copia de seguridad
backup_dir="$(dirname "$0")/backup_temp"
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

# Crear el archivo de log
echo "Inicio del backup: $(date)" > "$log_file"

# Obtener el nombre del usuario actual
current_user=$(whoami)

# Leer el archivo de rutas.txt, reemplazar %% por el usuario actual y hacer la copia de seguridad
while IFS= read -r line; do
    # Reemplazar %% por el nombre del usuario actual
    source="${line//%%/$current_user}"

    echo "Copiando de $source a $backup_dir/$(basename "$source")" >> "$log_file"
    
    # Copiar el contenido usando rsync (mejor opción en Linux para copias)
    rsync -a "$source" "$backup_dir/$(basename "$source")" >> "$log_file" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error al copiar de $source a $backup_dir/$(basename "$source")" >> "$log_file"
    else
        echo "Copia exitosa de $source a $backup_dir/$(basename "$source")" >> "$log_file"
    fi
done < rutas_linux.txt

# Comprimir la carpeta de respaldo en un archivo ZIP
zip -r "$zip_file" "$backup_dir" >> "$log_file" 2>&1

# Verificar si se creó correctamente el archivo ZIP
if [ -f "$zip_file" ]; then
    echo "Archivo ZIP creado exitosamente: $zip_file" >> "$log_file"
else
    echo "Error al crear el archivo ZIP" >> "$log_file"
fi

# Eliminar la carpeta temporal de respaldo
rm -rf "$backup_dir"

# Finalizar el proceso
echo "Backup completado: $(date)" >> "$log_file"
echo "Backup finalizado. Archivo de log creado en: $log_file"
            ;;
        2) 
            echo "Opción 2: Crear usuraio por fichero"
            crear_usuario
            ;;
        3) 
            echo "Opción 3: Modificar tarjeta de red"
            # Aquí puedes llamar a la función correspondiente o script
            modificar_red
            ;;
        4) 
            echo "Opción 4: Borrar archivos del log"
            # Aquí puedes llamar a la función correspondiente o script
            borrar_logs
            ;;
        5) 
            echo "Saliendo..."
            exit 0
            ;;
        *) 
            # Mensaje de error si la opción no es válida
            echo "El número \"$var\" no es una opción válida, por favor intente de nuevo."
            ;;
    esac

    echo
    read -p "Presiona Enter para continuar..."
    var="" # Reinicia 'var' para la próxima iteración
done
