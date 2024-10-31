#!/bin/bash

logfile="log.txt"
userfile="usuario.txt"
mailfile="gmail.txt"

# Esta funcion sirve para no poder ejecutar control +c para acabar el programa.
control_c(){
	echo "La interrupció del script amb Ctrl + C està deshabilitada, el script seguirà executant-se."
}

crear_usuario_automatico() {
    echo "Creant usuaris..." >> "$logfile"

    # Llegir usuaris des del fitxer en el format fullname:usuari:contrasenya
    while IFS=: read -r fullname username password; do
        # Comprovar que tots els valors estan presents
        if [ -z "$fullname" ] || [ -z "$username" ] || [ -z "$password" ]; then
            echo "Format incorrecte en el fitxer d'usuaris." >> "$logfile"
            echo "Format incorrecte en el fitxer d'usuaris."
            continue
        fi

        # Crear adreça de correu
        firstname=$(echo "$fullname" | awk '{print tolower(substr($1,1,1))}')  # Primera lletra del nom
        lastname=$(echo "$fullname" | awk '{print tolower($2)}')                # Cognom
        email="${firstname}${lastname}@script.com"                                # Correu inicial

        # Comprovar si el correu ja existeix en el fitxer
        if grep -q "$email" "$mailfile"; then
            count=1
            while grep -q "${firstname}${lastname}${count}@script.com" "$mailfile"; do
                ((count++))  # Incrementar contador si el correu ja existeix
            done
            email="${firstname}${lastname}${count}@script.com"  # Correu únic
        fi

        # Comprovar si l'usuari ja existeix
        if id "$username" &>/dev/null; then
            echo "L'usuari $username ja existeix." >> "$logfile"
            echo "L'usuari $username ja existeix."
        else
            # Crear l'usuari i establir la contrasenya
            if useradd -m "$username" >> "$logfile" 2>&1; then
                echo "$username:$password" | chpasswd >> "$logfile" 2>&1
                if [ $? -eq 0 ]; then
                    echo "Usuari $username creat amb èxit." >> "$logfile"
                    echo "Usuari $username creat amb èxit."

                    # Desar el correu electrònic en el fitxer
                    echo "$email":"$username" >> "$mailfile"
                    echo "Correu creat: $email" >> "$logfile"
                    echo "Correu creat: $email"
                else
                    echo "Error en establir la contrasenya per a l'usuari $username." >> "$logfile"
                    echo "Error en establir la contrasenya per a l'usuari $username."
                fi
            else
                echo "Error en crear l'usuari $username." >> "$logfile"
                echo "Error en crear l'usuari $username."
            fi
        fi
    done < "$userfile"

    echo "Procés de creació d'usuaris finalitzat." >> "$logfile"
    echo "Procés de creació d'usuaris finalitzat."
}


crear_usuario_manual() {
    echo "Creació manual d'usuaris..."

    while true; do
        read -p "Introdueix el nom d'usuari: " username
        if id "$username" &>/dev/null; then
            echo "L'usuari $username ja existeix."
            continue
        fi

        read -p "Introdueix la contrasenya: " -s password
        echo
        read -p "Confirma la contrasenya: " -s password_confirm
        echo

        if [ "$password" != "$password_confirm" ]; then
            echo "Les contrasenyes no coincideixen."
            continue
        fi

        read -p "Introdueix el nom complet: " fullname
        read -p "Introdueix el número d'habitació: " room
        read -p "Introdueix el número de telèfon: " phone
        read -p "Introdueix un altre dada (opcional): " other

        # Crear l'usuari i establir la contrasenya
        if adduser --gecos "$fullname,$room,$phone,$other" --disabled-password --allow-bad-names "$username"; then
            echo "$username:$password" | chpasswd
            echo "Usuari $username creat amb èxit."

            # Crear adreça de correu
            firstname=$(echo $fullname | awk '{print tolower(substr($1,1,1))}')
            lastname=$(echo $fullname | awk '{print tolower($2)}')
            email="${firstname}${lastname}@script.com"
            
            if grep -q "$email" "$mailfile"; then
                count=1
                while grep -q "${firstname}${lastname}${count}@script.com" "$mailfile"; do
                    ((count++))
                done
                email="${firstname}${lastname}${count}@script.com"
            fi

            echo $email >> "$mailfile"
            echo "Correu creat: $email"
        else
            echo "Error en crear l'usuari $username."
        fi

        read -p "Voleu crear un altre usuari? (s/n): " choice
        if [ "$choice" != "s" ]; then
            break
        fi
    done

    echo "Procés de creació d'usuaris finalitzat."
    echo
}

eliminar_usuario() {
    echo -n "Introdueix el nom d'usuari a eliminar: "
    read usuario

    # Confirmar si l'usuari existeix
    if id "$usuario" &>/dev/null; then
        echo "Estàs segur que vols eliminar l'usuari $usuario i tota la seva informació associada? (s/n)"
        read confirmacion
        if [[ $confirmacion == "s" ]]; then
            # Eliminar usuari i la seva carpeta d'inici
            sudo userdel -r "$usuario" 2>/dev/null && echo "L'usuari $usuario i la seva carpeta d'inici eliminats."

            # Eliminar el correu del fitxer especificat en mailfile
            correo="$(grep -E "^[^:]+:$usuario" "$mailfile")"
            if [[ -n $correo ]]; then
                sed -i "/^${correo//\//\\/}$/d" "$mailfile"
                echo "Correu associat a l'usuari $usuario eliminat de $mailfile."
            else
                echo "No s'ha trobat un correu associat en $mailfile."
            fi
        else
            echo "Eliminació cancel·lada."
        fi
    else
        echo "L'usuari $usuario no existeix."
    fi
}

modificar_usuario() {
    # Pide el nombre del usuario que se desea modificar
    echo -n "Introdueix el nom d'usuari a modificar: "
    read usuario

    # Verifica si el usuario existe en el sistema
    if id "$usuario" &>/dev/null; then
        # Menú de opciones limitado a las opciones especificadas
        echo "Què desitges modificar?"
        echo "1. Nom d'usuari"
        echo "2. Contrasenya"
        echo "3. Grup principal"
        echo "4. Grups addicionals"
        echo "5. Bloquejar o desbloquejar usuari"
	echo "6. Sortir"
        read -p "Indica quina opció vols triar: " opcio  # Llegeix l'opció elegida per l'usuari

        # Executa la modificació segons l'opció seleccionada
        case $opcio in
            1)
                # Cambia el nombre de usuario
                echo -n "Introdueix el nou nom d'usuari: "
                read nou_usuario
                sudo usermod -l "$nou_usuario" "$usuario"  # usermod -l per canviar el nom de l'usuari
                echo "Nom d'usuari actualitzat a $nou_usuario."
                ;;
            2)
                # Cambia la contraseña del usuario
                echo "Establint nova contrasenya per a $usuario."
                sudo passwd "$usuario"  # passwd obre un prompt per introduir la nova contrasenya
                ;;
            3)
                # Cambia el grupo principal del usuario
                echo -n "Introdueix el nou grup principal: "
                read nou_grup
                sudo usermod -g "$nou_grup" "$usuario"  # usermod -g estableix un nou grup principal per a l'usuari
                echo "Grup principal actualitzat."
                ;;
            4)
                # Afegix l'usuari a grups addicionals sense treure els grups actuals
                echo -n "Introdueix els grups addicionals (separats per comes): "
                read grups
                sudo usermod -aG "$grups" "$usuario"  # -aG afegeix l'usuari als grups especificats
                echo "Grups addicionals actualitzats."
                ;;
            5)
                # Menú addicional per bloquejar o desbloquejar l'usuari
                echo "1. Bloquejar usuari"
                echo "2. Desbloquejar usuari"
                read bloqueig_opcio  # Llegeix l'opció de bloquejar o desbloquejar
                if [[ $bloqueig_opcio -eq 1 ]]; then
                    sudo usermod -L "$usuario"  # -L bloqueja el compte d'usuari
                    echo "Usuari bloquejat."
                elif [[ $bloqueig_opcio -eq 2 ]]; then
                    sudo usermod -U "$usuario"  # -U desbloqueja el compte d'usuari
                    echo "Usuari desbloquejat."
                else
                    echo "Opció no vàlida."  # Missatge d'error si escull una opció incorrecta
                fi
                ;;
	    6)
		bash gestio_usuaris.sh
		;;
            *)
                # Missatge d'error si escull una opció de modificació invàlida
                echo "Opció no vàlida."
                ;;
        esac
    else
        # Missatge si l'usuari no existeix en el sistema
        echo "L'usuari $usuario no existeix."
    fi
}

trap control_c SIGINT

while true; do

clear

echo "BENVINGUTS A LA CONFIGURACIÓ D'USUARIS"
echo "1. Creació d'usuaris automàtics"
echo "2. Creació d'usuaris manual"
echo "3. Eliminació d'usuaris"
echo "4. Modificació d'usuaris"
echo "5. Sortir"
read -p "Indica quina opció vols triar: " opcio

case "$opcio" in

1)
	# Introduim el nom del primer fitxer
	crear_usuario_automatico
	;;
2)
	# Introduim el nom del segon fitxer
	crear_usuario_manual
	;;
3)
	# Introduim el nom del tercer fitxer
	eliminar_usuario
	;;
4)
	modificar_usuario
	;;
5)
	exit
	;;
*)
	echo "Opció no valida"
esac
	read -p "Prem l'enter per continuar"
done

