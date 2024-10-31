nombackup="backup"
filelog="gestiobackup.log"


# Esta funcion sirve para no poder ejecutar control +c para acabar el programa.
control_c(){
	echo "La interrupció del script amb Ctrl + C està deshabilitada, el script seguirà executant-se."
}

trap control_c SIGINT

#Esta es la funcion para crear el backup
crear_backup(){
	#Si la carpeta del nombre no existe creara la carpeta
	if [ ! -d $nombackup ];then
		mkdir $nombackup
		echo "S'ha creat la carpeta backup." >> $filelog
 		echo "S'ha creat la carpeta backup."
	fi


	#Seguidamente paso por pantalla un par de textos al usuario i le pido que rellene la variable carpeta seleccionada
	echo -e "\n"
	echo "A continuació, el que farem és crear una còpia de seguretat d'una carpeta. Aquesta còpia de seguretat es crearà en una carpeta anomenada $nombackup"
	read -p "Indica amb una ruta absoluta quina carpeta vols fer una còpia de seguretat: " carpetaSeleccionada


	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
	if [ ! -d "$carpetaSeleccionada" ];then
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es farà cap còpia de seguretat." >> $filelog
  		echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es farà cap còpia de seguretat."


	#Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
	elif [ -z "$(find "$carpetaSeleccionada" -mindepth 1 -print -quit)" ];then
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no es crearà la còpia de seguretat." >> $filelog
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no es crearà la còpia de seguretat."

	#Si no pasa nada de lo anterior el backup se crea i se pone dentro de la carpeta llamada backup
	else
		# Crear el archivo tar.gz con la fecha actual
	        tar --absolute-names -czvf "$nombackup/backup_$(basename "$carpetaSeleccionada")_$(date +%Y-%m-%d).tar.gz" "$carpetaSeleccionada"
	        echo "Backup creat correctament: $nombackup/backup_$(basename "$carpetaSeleccionada")_$(date +%Y-%m-%d).tar.gz" >> $filelog
	 	echo "Backup creat correctament: $nombackup/backup_$(basename "$carpetaSeleccionada")_$(date +%Y-%m-%d).tar.gz"
		sleep 3


	fi

}

borrar_bkps(){

	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
	if [ ! -d "$nombackup" ];then
	        echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no s'esborrarà cap còpia de seguretat." >> $filelog
	 	 echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no s'esborrarà cap còpia de seguretat."


	#Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
	elif [ -z "$(find "$nombackup" -mindepth 1 -print -quit)" ];then
	        echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no s'esborrarà la còpia de seguretat." >> $filelog
	  	echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no s'esborrarà la còpia de seguretat."

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
		    echo -e "\033[31mERROR:\033[0m Selecció invàlida. Si us plau, tria un número de la llista." >> $filelog
      		    echo -e "\033[31mERROR:\033[0m Selecció invàlida. Si us plau, tria un número de la llista."
		    exit 1
		fi

		# Obtener el archivo correspondiente a la selección
		archivo_a_eliminar=$(ls "$nombackup" | sed -n "${seleccion}p")

		# Confirmar la eliminación
		read -p "¿Estàs segur que vols eliminar el fitxer '$archivo_a_eliminar'? (s/n): " confirmacion

		if [[ "$confirmacion" =~ ^[sS]$ ]]; then
		    rm "$nombackup/$archivo_a_eliminar"
		    echo "Fitxer '$archivo_a_eliminar' ha estat eliminat." >> $filelog
      		    echo "Fitxer '$archivo_a_eliminar' ha estat eliminat."
		else
		    echo "Eliminació cancel·lada."
		fi
	fi


}

extraer_backups(){

	#Si no existe la carpeta seleccionada imprime por pantalla que hay un error i no se crea el backup
        if [ ! -d "$nombackup" ];then
                echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es farà cap còpia de seguretat." >> $filelog
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta no existeix, per tant no es farà cap còpia de seguretat."


        #Si existe la carpeta pero detecta que la variable ls -A es nula significa que la carpeta esta vacia, por lo tanto no hace falta hacer backup
        elif [ -z "$(find "$nombackup" -mindepth 1 -print -quit)" ];then
                echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no es crearà la còpia de seguretat." >> $filelog
		echo -e "\033[31mERROR:\033[0m Aquesta carpeta existeix, però està buida, per tant no es crearà la còpia de seguretat."

        else

                #Inicializamos un contador
                contador=1

                # Usar un bucle para listar los archivos con números
                echo "Fitxers en $nombackup:"
                for archivo in "$nombackup"/*; do
                    # Verificar si el archivo existe (en caso de que no haya archivos)
                    if [ -e "$archivo" ]; then
                        echo "$contador) $(basename "$archivo")"
                        ((contador++)) # Incrementamos el contador
                    fi
                done

                # Pedir al usuario que elija un archivo
                read -p "Selecciona el número del còpia de seguretat que desitges extreure: " seleccion

                # Verificar si la selección es un número válido
                if ! [[ "$seleccion" =~ ^[0-9]+$ ]] || [ "$seleccion" -lt 1 ] || [ "$seleccion" -ge "$contador" ]; then
                    echo -e "\033[31mERROR:\033[0m Selecció invàlida. Si us plau, tria un número de la llista." >> $filelog
		    echo -e "\033[31mERROR:\033[0m Selecció invàlida. Si us plau, tria un número de la llista."
                    exit 1
                fi

                # Obtener el archivo correspondiente a la selección
                archivo_a_extraer=$(ls "$nombackup" | sed -n "${seleccion}p")

		read -p "Indica en quina ruta vols extreure la còpia de seguretat: " ruta_extraccion

		if [ ! -d "$ruta_extraccion" ];then
			echo "La ruta que has indicat no existia, però s'ha creat a continuació" >> $filelog
  			echo "La ruta que has indicat no existia, però s'ha creat a continuació"
			mkdir -p "$ruta_extraccion"
		fi

                # Confirmar la eliminación
		read -p "¿Estàs segur que vols extreure el fitxer '$archivo_a_extraer'? (s/n): " confirmacion
		if [[ "$confirmacion" =~ ^[sS]$ ]]; then
		    tar -xvf "$nombackup/$archivo_a_extraer" -C "$ruta_extraccion"
		    echo "Fitxer '$archivo_a_extraer' ha estat extret a $ruta_extraccion." >> $filelog
       		    echo "Fitxer '$archivo_a_extraer' ha estat extret a $ruta_extraccion."
		read -p "Indica si vols eliminar la còpia de seguretat que has extret anteriorment (s/n): " confirmacio2

			echo "S'ha eliminat la còpia de seguretat"
			rm "$nombackup/$archivo_a_extraer"

		else
		    echo "Extracció cancel·lada."
		fi

        fi
}


while true; do

clear

echo "BENVINGUTS AL SCRIPT DE GESTIÓ DE COPIES DE SEGURETAT"
echo "1. Crear BackUps"
echo "2. Eliminar BackUps"
echo "3. Extreure Backups"
echo "4. Sortir"
echo -e "\n"
read -p "Indica quina opció vols triar: " opcio

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
	exit;;

*)
	echo -e "\033[31mERROR:\033[0m No existeix aquesta possibilitat moltes gràcies"

esac
	read -p "Prem el enter per continuar"
done
