# Esta funcion sirve para no poder ejecutar control +c para acabar el programa.
control_c(){
        echo "La interrupción del script con Ctrl + C está deshabilitado, el script seguirá ejecutándose."
}
 
trap control_c SIGINT



while true; do

clear

echo "BENVINGUTS AL NOSTRE SCRIPT AVANÇAT"
echo "1. Gestió d'usuaris"
echo "2. Gestió de copies de seguretat"
echo "3. "
echo "4. Sortir"
echo -e "\n"
read -p "Indica quina opció vols triar: " opcio

case "$opcio" in

1)
	# Introduim el nom del primer fitxer
	bash gestio_usuaris.sh;;
2)
	# Introduim el nom del segon fitxer
	bash gestio_backups.sh;;
3)
	# Introduim el nom del tercer fitxer
	bash script_gestion_apps;;
4)
	exit;;
*)
	echo -e "\033[31mERROR:\033[0m No existeix aquesta possibilitat moltes gràcies";;


esac
	read -p "Prem el enter per continuar"
done
