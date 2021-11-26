#!/bin/bash
clear
echo "Instal·lant glpi..."
echo "Comprovant connexió..."
ping -c5 google.com >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error de connexió a internet"
	exit
fi
echo "Comprovant usuari..."
usuari=$(whoami)
if [ $usuari != root ]; then
	echo "Entra com a root i torna a executar"
	exit
fi
echo "Actualitzant paquets..."
apt-get update >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error actualitzant paquets"
	exit
fi
echo "Instal·lant apache2..."
apt-get -y install apache2 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error instal·lant apache2"
	exit
fi
echo "Instal·lant mariadb-server..."
apt-get -y install mariadb-server >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error instal·lant mariadb"
	exit
fi
echo "Instal·lant php..."
apt-get -y install php php-mysql php-mbstring php-curl php-gd php-simplexml php-intl>/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Error instal·lant php"
	exit
fi
echo "Descarregant glpi..."
cd /opt/
wget -q https://github.com/glpi-project/glpi/releases/download/9.5.4/glpi-9.5.4.tgz
if [ $? -ne 0 ]; then
	echo "Error descarregant glpi"
	exit
fi
echo "Descomprimint glpi..." 
tar zxf glpi-9.5.4.tgz
if [ $? -ne 0 ]; then
	echo "Error descomprimint glpi"
	exit
fi
echo "Esborrant index.html..."
rm /var/www/html/index.html
if [ $? -ne 0 ]; then
	echo "Error esborrant index.html"
	exit
fi
echo "Movent glpi..."
mv /opt/glpi/* /var/www/html
if [ $? -ne 0 ]; then
	echo "Error movent glpi"
	exit
fi
echo "Donant permisos..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
if [ $? -ne 0 ]; then
	echo "Error donant permisos"
	exit
fi
echo "Creant Base de dades..."
mysql -u root -e "CREATE DATABASE glpi;"
if [ $? -ne 0 ]; then
	echo "Error creant base de dades"
	exit
fi
echo "Creant usuari"
mysql -u root -e "CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';"
if [ $? -ne 0 ]; then
	echo "Error creant usuari"
	exit
fi
echo "Donant permisos..."
mysql -u root -e "GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';"
if [ $? -ne 0 ]; then
	echo "Error donant permisos"
	exit
fi
echo "Actualitzant privilegis..."
mysql -u root -e "FLUSH PRIVILEGES;"
if [ $? -ne 0 ]; then
	echo "Error esborrant index.html"
	exit
fi
echo  "Reiniciant servidor web..."
systemctl restart apache2
if [ $? -ne 0 ]; then
	echo "Error reiniciant apache2"
	exit
fi
echo
echo "Instal·lació finalitzada :)"
echo 
echo "Usuari: glpi"
echo "Pswd: glpi"
echo "BD: localhost"
