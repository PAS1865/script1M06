nombackup="backup"
filelog="gestiobackup.log"


# Esta funcion sirve para no poder ejecutar control +c para acabar el programa.
control_c(){
        echo "La interrupcion de la script con Cntrl + C esta deshabilitada, el script seguira ejecutandose."
}

trap control_c SIGINT

#Esta es la funcion para crear el backup
crear_backup(){
	#Si la carpeta del nombre no existe creara la carpeta
	if [ ! -d $nombackup ];then
		mkdir $nombackup
		echo "Se ha creado la carpeta backup" >> $filelog
	fi


	#Seguidamente paso por pantalla un par de textos al usuario i le pido que rellene la variable carpeta seleccionada
	echo -e "\n"
	echo "A continuació el que farem es crear un backup d'una carpeta, aquest backup es creara amb una carpeta anomenada $nombackup"
	read -p "Indica amb una ruta absoluta quina carpeta vols fer un backup: " carpetaSeleccionada


	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
	if [ ! -d "$carpetaSeleccionada" ];then
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es fara cap backup." >> $filelog


	#Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
	elif [ -z "$(find "$carpetaSeleccionada" -mindepth 1 -print -quit)" ];then
		echo -e "\033[31mERROR:\033[0m Esta carpeta existe pero esta vacia, por tanto no se creara el backup." >> $filelog


	#Si no pasa nada de lo anterior el backup se crea i se pone dentro de la carpeta llamada backup
	else
		# Crear el archivo tar.gz con la fecha actual
	        tar --absolute-names -czvf "$nombackup/backup_$(basename "$carpetaSeleccionada")_$(date +%Y-%m-%d).tar.gz" "$carpetaSeleccionada"
	        echo "Backup creat correctament: $nombackup/backup_$(basename "$carpetaSeleccionada")_$(date +%Y-%m-%d).tar.gz" >> $filelog
		sleep 3


	fi

}

borrar_bkps(){

	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
	if [ ! -d "$nombackup" ];then
	        echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es fara cap backup." >> $filelog


	#Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
	elif [ -z "$(find "$nombackup" -mindepth 1 -print -quit)" ];then
	        echo -e "\033[31mERROR:\033[0m Esta carpeta existe pero esta vacia, por tanto no se borrara el backup." >> $filelog

	else

		#Inicializamos un contador
		contador=1

		# Usar un bucle para listar los archivos con números
		echo "Archivos en $nombackup:"
		for archivo in "$nombackup"/*; do
		    # Verificar si el archivo existe (en caso de que no haya archivos)
		    if [ -e "$archivo" ]; then
		        echo "$contador) $(basename "$archivo")"
		        ((contador++)) # Incrementamos el contador
		    fi
		done

		# Pedir al usuario que elija un archivo
		read -p "Selecciona el número del archivo que deseas eliminar: " seleccion

		# Verificar si la selección es un número válido
		if ! [[ "$seleccion" =~ ^[0-9]+$ ]] || [ "$seleccion" -lt 1 ] || [ "$seleccion" -ge "$contador" ]; then
		    echo -e "\033[31mERROR:\033[0m Selección inválida. Por favor, elige un número de la lista." >> $filelog
		    exit 1
		fi

		# Obtener el archivo correspondiente a la selección
		archivo_a_eliminar=$(ls "$nombackup" | sed -n "${seleccion}p")

		# Confirmar la eliminación
		read -p "¿Estás seguro de que deseas eliminar el archivo '$archivo_a_eliminar'? (s/n): " confirmacion

		if [[ "$confirmacion" =~ ^[sS]$ ]]; then
		    rm "$nombackup/$archivo_a_eliminar"
		    echo "El archivo '$archivo_a_eliminar' ha sido eliminado." >> $filelog
		else
		    echo "Eliminación cancelada."
		fi
	fi


}

extraer_backups(){

	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
        if [ ! -d "$nombackup" ];then
                echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es fara cap backup." >> $filelog


        #Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
        elif [ -z "$(find "$nombackup" -mindepth 1 -print -quit)" ];then
                echo -e "\033[31mERROR:\033[0m Esta carpeta existe pero esta vacia, por tanto no se creara el backup." >> $filelog

        else

                #Inicializamos un contador
                contador=1

                # Usar un bucle para listar los archivos con números
                echo "Archivos en $nombackup:"
                for archivo in "$nombackup"/*; do
                    # Verificar si el archivo existe (en caso de que no haya archivos)
                    if [ -e "$archivo" ]; then
                        echo "$contador) $(basename "$archivo")"
                        ((contador++)) # Incrementamos el contador
                    fi
                done

                # Pedir al usuario que elija un archivo
                read -p "Selecciona el número del backups que deseas extraer: " seleccion

                # Verificar si la selección es un número válido
                if ! [[ "$seleccion" =~ ^[0-9]+$ ]] || [ "$seleccion" -lt 1 ] || [ "$seleccion" -ge "$contador" ]; then
                    echo -e "\033[31mERROR:\033[0m Selección inválida. Por favor, elige un número de la lista." >> $filelog
                    exit 1
                fi

                # Obtener el archivo correspondiente a la selección
                archivo_a_extraer=$(ls "$nombackup" | sed -n "${seleccion}p")

		read -p "Indica en que ruta quieres extraer el backup: " ruta_extraccion

		if [ ! -d "$ruta_extraccion" ];then
			echo "La ruta que has indicado no existia, pero se ha creado acontinuacion" >> $filelog
			mkdir -p "$ruta_extraccion"
		fi

                # Confirmar la eliminación
		read -p "¿Estás seguro de que deseas extraer el archivo '$archivo_a_extraer'? (s/n): " confirmacion
		if [[ "$confirmacion" =~ ^[sS]$ ]]; then
		    tar -xvf "$nombackup/$archivo_a_extraer" -C "$ruta_extraccion"
		    echo "El archivo '$archivo_a_extraer' ha sido extraído en $ruta_extraccion." >> $filelog
		read -p "Indica si vols eliminar el backup que has extret anteriorment (s/n): " confirmacio2

		if [ $confirmacio2 ! -eq ]; then


			echo "Se ha eliminado el backup"
			rm "nombackup/$archivo_a_extraer"

		else
			echo "No se ha eliminat el backup"
		fi

		else
		    echo "Extración cancelada."
		fi

        fi
}


while true; do

clear

echo "BENVINGUTS AL SCRIPT DE GESTIO DE COPIES DE SEGURETAT"
echo "1. Crear BackUps"
echo "2. Eliminar BackUps"
echo "3. Extraer Backups"
echo "4. "
echo "5. Salir"
echo -e "\n"
read -p "Indica quina opcio vols triar: " opcio

case "$opcio" in

1)
	# Introduim el nom del primer fitxer
	crear_backup;;
2)
	# Introduim el nom del segon fitxer
	borrar_bkps;;
3)
	# Introduim el nom del tercer fitxer
	extraer_backups;;
4)
	# Introduim el nom del quart fitxer
 	quart;;
5)
	exit;;

*)
	echo -e "\033[31mERROR:\033[0m No existeix aquesta possibilitat moltes gràcies"

esac
	read -p "Prem el enter per continuar"
done
