#!/usr/bin/env bash

# Bash doesn't like spaces before or after the '=' sign when assignning commandline args to local variables
SERVER_NAME=$1
SERVER_ALIAS=$2
DB_NAME=$3
DB_USER=$4
DB_PASS=$5

echo "************************************************"
echo "Building server with:"
echo "SERVER_NAME  = $1"
echo "SERVER_ALIAS = $2"
echo "DB_NAME      = $3"
echo "DB_USER      = $4"
echo "DB_PASS      = $5"
echo ""
echo "************************************************"
echo ""
echo ""

echo "***************************************************"
echo "***Set Sever Time Zone To EST***"
echo "***************************************************"
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/America/New_York /etc/localtime




echo "***************************************************"
echo "***Installing Apache***"
# echo "***************************************************"
sudo apt-get update
sudo apt-get install -y apache2
# sudo apt-get install mysql-server
# sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
# sudo apt-get install -y apache2 php5 libapache2-mod-php5 php5-mcrypt debconf-utils # install apache2 and php5
# Required for WP User Photo plugin
#sudo apt-get -y install php5-gd 
echo ""
echo ""

echo "***************************************************"
echo "**************** Installing MYSQL *****************"
echo "***************************************************"

export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant' # enter your database's root password 
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant' # re-enter your database's root password
sudo apt-get install -y mysql-server # install mysql-server. This will prompt for a password and re-enter password, the above two lines will be used for selection
sudo sed -i -- 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart
echo ""
echo ""

echo "***************************************************"
echo "*** Installing PHP ***"
echo "***************************************************"
sudo apt-get install -y php libapache2-mod-php php-mcrypt php-mysql
echo ""
echo ""

echo "***************************************************"
echo "*** Installing PHP Modules ***"
echo "***************************************************"
# sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
sudo apt-get install -y curl
sudo service apache2 restart
sudo apt-get install -y php-curl
sudo service apache2 restart
echo ""
echo ""

echo "***************************************************"
echo "*** create a symlink for /vagrant from /var/www ***"
echo "***************************************************"
echo ""
echo "Creating symlink"
rm -rf /var/www # remove /var/www, this will be symlinked later
ln -fs /vagrant/src /var/www # create a symlink for /vagrant from /var/www
echo ""
echo ""


echo "***************************************************"
echo "*************** Create Apache Vhost ***************"
echo "***************************************************"

a2enmod rewrite # enable the mod_rewrite apache2 mod. This will be needed for the next step
# Create a new apache config for your site
cat >/etc/apache2/sites-available/$SERVER_NAME.conf <<EOL
<VirtualHost *:80>
  ServerName $SERVER_NAME
  ServerAlias $SERVER_ALIAS
  DocumentRoot /var/www/public_html
  <Directory /var/www/public_html>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.php [QSA,L]
  </Directory>
</VirtualHost>
EOL

sudo a2dissite 000-default # disable the default apache site config
sudo a2ensite $SERVER_NAME.conf # enable your site's config that you just created above

sudo service apache2 restart # restart apache


echo "***************************************************"
echo "***************** Create Database *****************"
echo "***************************************************"
echo "Creating DATABASE: ${DB_NAME}"
mysql -u root -pvagrant -e "CREATE DATABASE ${DB_NAME};" # Creates a new database in mysql. Use the same name as your production database
echo "Creating user: ${DB_USER}  pass: ${DB_PASS}"
mysql -u root -pvagrant -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';" # creates a new mysql user, use the same name and password as your production
echo "Granting ALL Priveleges to '${DB_USER}'@'%'"
mysql -u root -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%';" # For a production or a publicly accessable database you would not normally grant all privileges across all databases
echo "FLUSHING PRIVILEGES"
mysql -u root -pvagrant -e "FLUSH PRIVILEGES;" # reload the privileges table
echo ""
echo ""

echo "***************************************************"
echo "****************** Seed Database ******************"
echo "***************************************************"
echo "SEEDING DATABASE"
#mysql -u root -pvagrant $DB_NAME < /vagrant/db.sql # load the schema and seed the new database from your production dump
#TODO run cron to create current month's file
echo ""
echo ""

echo "***************************************************"
echo "****************** Setup Complete *****************"
echo "***************************************************"
echo "  Server Setup:"
echo "    SERVER_NAME  = $1"
echo "    SERVER_ALIAS = $2"
echo "    DB_NAME      = $3"
echo "    DB_USER      = $4"
echo "    DB_PASS      = $5"
echo ""
echo "run 'vagrant ssh' to get instructions to SSH into box."
echo "************************************************"