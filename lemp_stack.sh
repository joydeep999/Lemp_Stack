#Checking the user is root or not
#!/bin/bash
			echo "Checking if the user is root or not"
		if [[ $EUID -ne 0 ]]; then
			echo "Please run this script as a root"
			sleep 2
    	exit 1
    else
      echo "User is root"
			echo "Updating the package repository, Might take some time"
			sleep 2
      apt-get update && apt-get upgrade -y
      sleep 2
   	fi

#Checking Nginx And Installing if not present 

       echo "Checking Nginx"
		if [[ -e /var/run/nginx.pid && -e /etc/nginx/nginx.conf ]]; then
       echo "Nginx is running and configured according to scripts requirement"
    else

#apt-get purge will remove all the config files, and provide a clean enviornment to reinstall Nginx from scratch

			echo "Installing Nginx"
			sleep 2
      apt-get purge nginx nginx-common -y && apt-get autoremove -y && apt-get autoclean -y
      sleep 2
			echo "Installing Required Compilers and Packages that are needed by nginx"
			sleep 2
			apt-get install build-essential -y
			sleep 2
			echo "Installing LIBPCRE ZLIB SSL-LIB"
			sleep 2
			apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev -y
			sleep 2
			echo "All dependent packages are installed, Hence installing Nginx now"
			sleep 2
			apt-get install nginx -y
			sleep 2
			nginx
			systemctl enable nginx && systemctl restart nginx
			ps -ef|grep nginx
			echo "Above o/p shows Nginx process are running"
			sleep 2				
   fi

#Checking PHP And Installing if not present 

			echo "Checking PHP is present or not"
			php_check=$(php -v|wc -l)
	if [[ $php_check -gt 1 && -e /var/run/php ]]; then
			echo "PHP is present according to the requirement of the script"
	else

#apt-get purge will clear all the files related to php and reinstall from scratch

			echo "Installing PHP"
			sleep 2
			apt-get purge php php-fpm php-gd php-mysql -y && apt-get autoremove -y && apt-get autoclean -y
			sleep 2
			apt-get install php php-cli php-common php-fpm php-mysql php-gd -y
			sleep 2
			chmod 777 /var/run/php/*
	fi
			php_sock=$(ls -ltr /var/run/php|grep www|cut -d" " -f10)

#Checking MySql And Installing if not present 

			echo "Checking if MySql exists or not"
			service mysql start
			mysql_check=$(ps -ef|grep mysql|wc -l)
	if [[ $mysql_check -gt 1 && -e /etc/mysql/mysql.cnf ]]; then
			echo "MySql is Present"
			phpenmod mysql
	else

#apt-get purge will clear all the files related to mysql and reinstall from scratch

			echo "Installing Mysql"
			sleep 2
			apt-get purge mysql mysqli -y && apt-get autoremove -y && apt-get autoclean -y
			apt-get install mysql-server -y
			service mysql start	
	fi

#Prompting user to input a valid domain name and creating an entry on /etc/hosts once domain name is validated 

			echo "Enter Domain name"
			read dom_name
			regx='^[a-zA-Z0-9][a-zA-Z0-9-][a-zA-Z0-9.]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,6}$'
	while [[ !( $dom_name =~ $regx ) ]];
	do
			echo "Enter a Proper Domain name"
			read dom_name
	done
			echo "Now the enetered Domain name $dom_name looks good"
			echo "Creating an Entry in /etc/hosts"
			sleep 2
			echo "127.0.0.1  $dom_name" >> /etc/hosts

#Creating Nginx.conf file 

			echo "Now Creating a WordPress Setup, Please do not interrupt the process"
			sleep 2
			wget -P /site/ -q http://wordpress.org/latest.zip
			unzip /site/latest.zip -d /site/
			echo "Creating Nginx Conf file"
			sleep 2
				echo "
				user www-data;
				worker_processes auto;
				events {}
				http {
				include mime.types;
				gzip on;
				gzip_comp_level 3;
				gzip_types text/css;
				gzip_types text/javascript;
				fastcgi_cache_path /tmp/nginx levels=1:2 keys_zone=zone_1:100m inactive=4m;
				fastcgi_cache_key "$scheme$request_method$host$request_uri";
				add_header X-Cache $upstream_cache_status;
				server {
				listen 80;
				server_name $dom_name;
				root /site/wordpress;
				index index.php index.html;
				location ~\.php$ {
				include fastcgi.conf;
				fastcgi_pass unix:/run/php/$php_sock;
				fastcgi_cache zone_1;
				fastcgi_cache_valid 200 4m;
				}
				}
				}" > /etc/nginx/nginx.conf
			echo "Rebouncing Nginx"
			sleep 2
			systemctl reload nginx

#Extracting name for the Database

			db_name=${dom_name%%.*}_db
			user_name=user1
			password=someday123
			echo "$db_name is your Database Name"
			echo "Creating a Database for your site"
			mysql -e "create database $db_name;"
			mysql -e "create user $user_name@localhost IDENTIFIED BY '$password';"
			mysql -e "grant all privileges on $db_name to '$user_name'@'localhost';"
			mysql -e "flush privileges;"

#Creating wp-config.php file for Database connectivity 

			touch /site/wordpress/wp-config.php
			echo "
				define( 'DB_NAME', '$db_name' );
				define( 'DB_USER', '$user_name' );
				define( 'DB_PASSWORD', '$password' );
				define( 'DB_HOST', 'localhost' );
				define( 'DB_CHARSET', 'utf8mb4' );
				define( 'DB_COLLATE', '' );
				define( 'AUTH_KEY',         '^_V {CeeRYO]Pieq$6!q_kXua/lituKF~Anj{y-0%^V)[KxA_4Nh+Ko^)NYo97F+' );
				define( 'SECURE_AUTH_KEY',  'oIifl#6v=V9.1ww4>)v.%lG<YLo0bcdz_zy@I&o8pR)$3d5$b}H[66xc{$Z{vZJL' );
				define( 'LOGGED_IN_KEY',    '6TMVY%i{Ov20ew2NnG1|)3n9MAv<hR%HO,<WX0YGG4#`Y|+zswBdp830w >Gk[q#' );
				define( 'NONCE_KEY',        '>?66=V+4XqyixcXoEtP4t[xG><#I+c5+zEr7K~IrFj>Id$iPiBg]E-L[/Kp75u@ ' );
				define( 'AUTH_SALT',        '1l~]#,4wpmn+EH]yO7X9Znl[b7~aLHF +$<PuP=cTYnr.]yfx6]6~T:*J7OmiojO' );
				define( 'SECURE_AUTH_SALT', '!enI!?ysaDa&0 4m@J,m!;U=p{vXQj]]T}K/+!rvX9,L1$r{^kpRCbNrsm[SJO`$' );
				define( 'LOGGED_IN_SALT',   '-U)F@ld+1~:g~*!0X,HRSwH83Bh_hU:ic[aw6(*Bc&!vsdM2!bZ].s)p?:~w(p_?' );
				define( 'NONCE_SALT',       '>Bts/T6eCr?9XkqiWXC+=t[m@}.-Z*^0c4.f&8yKI^>D?ltBsS;g6@Dp.mE=}=A|' );
				$table_prefix = 'wp_';
				define( 'WP_DEBUG', false );
				define( 'WP_DEBUG', false );
				if ( ! defined( 'ABSPATH' ) ) {
				define( 'ABSPATH', __DIR__ . '/' );
				}
				require_once ABSPATH . 'wp-settings.php';
				" > /site/wordpress/wp-config.php
			sleep 2
			systemctl reload nginx
			sleep 2
			echo "Your Website is believed to be ready now, Please check it out on your browser hitting the domain name you entered"
			
