# Introduction

* The script (lemp_stack.sh) in this repo will automate builiding an testing enviornment for the WordPress developers.
* This script is also an challenge(Challenge A) from rtCamp to setup a lemp stack server.


# Assumptions

* This script will help create a Test enviornment for the WordPress developers.
* All the needed packages will be installed and will be running with the necessary configurations for Webserver (Nginx).
* Developers would just have to put their .php files under the /site/wordpress directory.
* This script will also ask you to enter a valid domain name, that you want to give to your website, And when you hit your entered domain name in the address bar of the browser it will point to the localhost where changes made to site will reflect.

# Libraries Used

* libpcre3 libpcre3-dev (Perl Compatible Regular Expressions) in Nginx to include regular expressions.
* zlib1g zlib1g-dev - zlib is a library implementing the deflate compression method found in gzip.
* libssl-dev - libssl is the portion of OpenSSL which supports TLS ( SSL and TLS Protocols ), and depends on libcrypto.
* libgd-dev - GD is a graphics library. It allows your code to quickly draw images complete with lines, arcs, text, multiple colours, cut and paste from other images, flood fills, and write out the result as a PNG file.

# Script Manual

* The script should be executed under **root** user priveleges only.

* The script will check if **Nginx, PHP, Mysql** are installed or not, and if not, it will install all the required packages for the same.

* For Nignix it will check for the configuration files under **/etc/nginx** and will check for **/var/run/nginx.pid** file. If both are present only then it will continue with further execution of the script or else it will **Download and Install Nginx from scratch**.

* For PHP it will check if php is present, by checking for php version and if the required files are present under the **/var/run/php**. If both conditions are true only then the script will continue further execution or else it will first clear out all the php configuration files and reinstalling PHP from the scratch with all the required packages.

* For MySql it will check if the mysql process is running or not and will also check the **mysql.cnf** file under the **/etc/mysql** directory. If both conditions are true only then the script will continue further execution or else it will first clear out all the MySql configuration files and reinstalling it from the scratch with all the required packages.

* Once all the needed packages are installed, Now the script will prompt the user to **input a valid domain name** he wants to assign to his project. Remember the domain name should be a standard domain name according to the domain naming conventions or else it will ask you to enter a valid domain name until it gets the domain name according to its valid domain expression mentioned in the script.

* The entered domain name will create an entry into the **/etc/hosts** file pointing to the localhost. An **nginx.conf** file will be created accordingly.

* WordPress will be downloaded and unzipped at **/site/wordpress** directory of your fileSystem.

* A Database will be created with the name **$domain_name_db** and the userid and password will be - **"user1" and "someday123"**. A **wp-config.php** file will be created under **/site/wordpress**.

* At last the Nginx will be **reloaded/restarted**.

* If everything goes all right you will be prompted to open your **website onto the browser**.
