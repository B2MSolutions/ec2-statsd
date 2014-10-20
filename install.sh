#!/bin/bash -v
set -e
echo 'update, upgrade and install'
sudo apt-get update
sudo apt-get upgrade --assume-yes
sudo apt-get install --assume-yes apache2 apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common libapr1 libaprutil1 libaprutil1-dbd-sqlite3 build-essential python3.2 python-dev libpython3.2 python3-minimal libapache2-mod-wsgi libaprutil1-ldap memcached python-cairo-dev python-django python-ldap python-memcache python-pysqlite2 sqlite3 erlang-os-mon erlang-snmp rabbitmq-server bzr expect libapache2-mod-python python-setuptools
sudo easy_install django-tagging==0.3.1 zope.interface twisted txamqp

echo 'wget and extract graphite, carbon and whisper'
cd ~
wget https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz
wget https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz
wget https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz
tar -zxvf graphite-web-0.9.10.tar.gz
tar -zxvf carbon-0.9.10.tar.gz
tar -zxvf whisper-0.9.10.tar.gz

echo 'install whisper'
cd whisper*
sudo python setup.py install

echo 'install carbon'
cd ../carbon*
sudo python setup.py install

echo 'install graphite'
cd ../graphite*
sudo python check-dependencies.py
sudo python setup.py install

echo 'configure graphite'
cd /opt/graphite/conf
sudo cp carbon.conf.example carbon.conf
sudo echo '[stats]' > storage-schemas.conf
sudo echo 'priority = 110' >> storage-schemas.conf
sudo echo 'pattern = .*' >> storage-schemas.conf
sudo echo 'retentions = 10:2160,60:10080,600:262974' >> storage-schemas.conf
cd /opt/graphite/webapp/graphite/

# echo 'install 0.3.1 django-tagging'
# https://www.digitalocean.com/community/tutorials/installing-and-configuring-graphite-and-statsd-on-an-ubuntu-12-04-vps#comment_10382
# sudo pip uninstall django-tagging 
# sudo pip install django-tagging==0.3.1

echo 'manage database'
sudo python manage.py syncdb
sudo cp local_settings.py.example local_settings.py
sudo cp ~/graphite*/examples/example-graphite-vhost.conf /etc/apache2/sites-available/default
sudo cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
sudo chown -R www-data:www-data /opt/graphite/storage
sudo mkdir -p /etc/httpd/wsgi
