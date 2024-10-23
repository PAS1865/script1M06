while true; do

clear

echo "BENVINGUTS A LA PRIMERA OPCIO"
echo "1. Gestio d'usuaris"
echo "2. Gestio de copias de seguretat"
echo "3. "
echo "4. "
echo "5. Salir"
read -p "Indica quina opcio vols triar: " opcio

case "$opcio" in

1)
	# Introduim el nom del primer fitxer
	crear_usuario;;
2)
	# Introduim el nom del segon fitxer
	bash gestio_backups.sh;;
3)
	# Introduim el nom del tercer fitxer
	tercer;;
4)
	# Introduim el nom del quart fitxer
 	quart;;
5)
	exit;;

esac
	read -p "Prem el enter per continuar"
done
