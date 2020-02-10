#!/bin/bash

#installing wordpress on ubuntu 18.04

#1. update system
#2. ask php and wordpress-version,database-name, database-username, database-password 
#3. install php, mysql, nginx and other dependencies
#4. fetch wordpress specified version
#5. extract and copy wordpress to /var/www/html/sitename.com
#6. create database and create user with given details in step 2
#7. modify nginx file and restart nginx
print_version_info(){
	cat <<END
	1. Php version : 		$1
	2. Wordpress version: 	$2
	3. Database name: 		$3
	4. Datbase usernmae: 	$4
	4. Database password: 	$5
	5. Site Domain Name: 	$6
END
}
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

# 
# script start
# 

echo -e "\n\n1.) Which php version you want to intall?"
read vphp

echo -e "\n2.) Which wordpress version you want to install?"
read vwp

echo -e "\n3.) Please enter your database name."
read dbname

echo -e "\n4.) Please enter database username."
read dbuname

echo -e "\n5.) Please enter database password."
read dbpwd

echo -e "\n6.) Please enter your site domain name. Example: geekconsults.co.in "
read sitename

echo -e "\n\nPlease keep the above entered information handy and keep it handy as it will required during wordpress setup."

print_version_info $vphp $vwp $dbname $dbuname $dbpwd $sitename

echo -e "\n\nAre you sure you want to continue installation? y/n"
read -n 1 confirm_install

#exit if not confirm installation
if [[ "$confirm_install" != "y" ]]
	echo "\n\nProgram Terminated..."
	exit 0
fi

# 
#installtion of dependencies
# 

# php 7.1 wp 5.2.3 5.3
sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt -y update
sudo apt -y upgrade

echo "Installing php${vphp}.."
sudo apt -y install php${vphp}-cli php${vphp}-fpm php${vphp}-mysql php${vphp}-json php${vphp}-opcache php${vphp}-mbstring php${vphp}-xml php${vphp}-gd php${vphp}-curl
echo -e "Php installed successfully!\n"

echo "Installing nginx"
sudo apt -y install nginx
echo "Nginx installed successfully!\n"

echo "Installing mysql-server"
sudo apt -y install mysql-server
echo "Mysql installed successfully!\n"

default_dir=$PWD
#creating database
run_sql_commands $dbname $dbuname $dbpwd

#fetching wordpress
cd /tmp
wget https://wordpress.org/wordpress-$vwp.tar.gz
tar -xzvf wordpress-$vwp.tar.gz

sudo mkdir /var/www/html/$sitename
sudo mv /tmp/wordpress/* /var/www/html/$sitename

sudo chown -R www-data: /var/www/html/$sitename

#Note that Nginx and PHP run as the www-data user and group, hence this is used in the above command.
#Reason : If it were run under root, then all the files would have to be accessible by root and the user would need to be root to access the files. With root being the owner, a compromised web server would have access to your entire system. By specifying a specific ID a compromised web server would only have full access to its files and not the entire server.


#creating nginx site and updating nginx conf file
cd $default_dir
cp nginx.conf /tmp/$sitename
sed -i "s/domain.tld/$sitename/g" /tmp/$sitename
sed -i "s/_vphp_/$vphp/g" /tmp/$sitename    
sudo mv /tmp/$sitename /etc/nginx/sites-available/                                                      
# cd /etc/nginx/sites-available
sudo ln -s /etc/nginx/sites-available/$sitename /etc/nginx/sites-enabled/

echo "Hurray!! All done. Restarting server..."
sudo systemctl restart nginx

echo -e "\nWordpress installation completed successfully!"
echo -e "\n\nPlease keep the below information safe for future reference."
print_version_info $vphp $vwp $dbname $dbuname $dbpwd $sitename


#copy all creds and version in a text file and tell about that to user



