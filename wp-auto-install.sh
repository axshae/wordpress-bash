#!/bin/bash

#installing wordpress on ubuntu 18.04

#1. update system
#2. ask php and wordpress-version,database-name, database-username, database-password 
#3. install php, mysql, nginx and other dependencies
#4. fetch wordpress specified version
#5. extract and copy wordpress to /var/www/html/sitename.com
#6. create database and create user with given details in step 2
#7. modify nginx file and restart nginx
run_sql_commands(){

	dbname=$1
	dbuname=$2
	dbpwd=$3
	charset="utf8mb4"
	collate="utfmb4_general_ci"
	echo "Creating new MySQL database..."
	mysql -e "CREATE DATABASE ${dbname} /*\!40100 DEFAULT CHARACTER SET ${charset} COLLATE ${collate}; */;"
	echo "Database successfully created!"
	echo ""
	mysql -e "CREATE USER ${dbuname}@localhost IDENTIFIED BY '${dbpwd}';"
	echo "User successfully created!"
	echo ""
	echo "Granting ALL privileges on ${dbname} to ${dbuname}!"
	mysql -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${dbuname}'@'localhost';"
	mysql -e "FLUSH PRIVILEGES;"
	
}

# php 7.1 wp 5.2.3 5.3
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt upgrade

echo "php version?"
read vphp

echo "wordpress version ?"
read vwp

echo "database name?"
read dbname

echo "database username?"
read dbuname

echo "database password?"
read dbpwd

echo "Site name?"
read sitename

echo "Installing php${vphp}.."
sudo apt install php${vphp}-cli php${vphp}-fpm php${vphp}-mysql php${vphp}-json php${vphp}-opcache php${vphp}-mbstring php${vphp}-xml php${vphp}-gd php${vphp}-curl
echo -e "Php installed successfully!\n"

echo "Installing nginx"
sudo apt install nginx
echo "Nginx installed successfully!\n"

echo "Installing mysql-server"
sudo apt install mysql-server
echo "Mysql installed successfully!\n"

#creating database
run_sql_commands $dbname $dbuname $dbpwd

#fetching wordpress
cd /tmp
wget https://wordpress.org/wordpress-$vwp.tar.gz
tar -xzvf wordpress-$vwp.tar.gz

sudo mkdir /var/www/html/$sitename
sudo mv /tmp/wordpress-$vwp/* /var/www/html/$sitename

sudo chown -R www-data: /var/www/html/$sitename

#Note that Nginx and PHP run as the www-data user and group, hence this is used in the above command.
#Reason : If it were run under root, then all the files would have to be accessible by root and the user would need to be root to access the files. With root being the owner, a compromised web server would have access to your entire system. By specifying a specific ID a compromised web server would only have full access to its files and not the entire server.


#creating nginx site and updating nginx conf file
cp nginx.conf /tmp/$sitename
sed -i "s/domain.tld/$sitename/g" /tmp/$sitename
sed -i "s/vphp/$vphp/g" /tmp/$sitename    
sudo mv /tmp/$sitename /etc/ngix/sites-available/                                                      
# cd /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/

echo "Hurray!! All done. Restarting server..."
sudo systemctl restart nginx

echo -e "\nWordpress setup completed successfully!"




