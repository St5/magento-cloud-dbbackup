#!/bin/bash
#version 1.0.0

# Configurations
DumpDir="/var/www/Dump"
dbuser="admin"
dbpass="admin"
host="0.0.0.0"

# Checking arguments
if [ $# -eq 0 ]; then
    echo "You don't enter env."
    exit 1
fi

# Current directory
current_dir=$(pwd)

# Parameters
env=$1
timestamp=$(date +"%Y%m%d%H%M")

filename="${current_dir##*/}_${env}_$timestamp.sql.zip"
dbname="${current_dir##*/}_${env}_$(date +"%Y%m%d")"

# Downloading DB from Magento Cloud
echo "Start download DB: magento-cloud db:dump -z -f $filename -e $env"
magento-cloud db:dump -z -f $filename -e $env
echo "DB was uploaded"

# Copying dump file to the storage dumps directory
mv "$filename" "$DumpDir"
echo "The file was copied to $DumpDir"

filename="$DumpDir/${current_dir##*/}_${env}_$timestamp.sql.zip"
# Unzipping the dump file
unzip_filename="$DumpDir/${current_dir##*/}_${env}_$timestamp.sql"
gunzip -c "$filename" > "$unzip_filename"
echo "The file was unarchived to $unzip_filename"

# Verify if the database exists
DB_EXISTS=$(mysql -h "$host" -u"$dbuser" -p"$dbpass" -e "SHOW DATABASES LIKE '$dbname';" | grep "$dbname")

if [ "$DB_EXISTS" ]; then
  echo "Database $dbname already exists. Do you want to delete it? (Y/n)"
  read -r response
  if [[ "$response" == "Y" || "$response" == "y" || "$response" == "" ]]; then
    mysql -h "$host" -u"$dbuser" -p"$dbpass" -e "DROP DATABASE $dbname;"
    echo "Database $dbname was deleted"
  else
    echo "Exiting script."
    exit 0
  fi
fi

# Create a new database
mysql -h "$host" -u"$dbuser" -p"$dbpass" -e "CREATE DATABASE $dbname;"
echo "$dbname was created"

# Import the database
echo "Import DB is starting..."
echo "mysql -h $host -u$dbuser -p$dbpass $dbname < $unzip_filename"
mysql -h "$host" -u"$dbuser" -p"$dbpass" "$dbname" < "$unzip_filename"
echo "Import was finished"

# Ask if the user wants to delete the dump file
read -p "Do you want to delete the dump file? [Y/n]: " delete_file
if [ "$delete_file" == "Y" ] || [ "$delete_file" == "y" ] || [ "$delete_file" == "" ]; then
    rm "$unzip_filename"
    echo "The file was deleted($unzip_filename)"
else
    echo "The file of extract db was saved($unzip_filename)"
fi

# Ask if the user wants to update app/etc/env.php with the new database name
echo "Do you want to update app/etc/env.php with the new database name? (Y/n)"
read -r update_response
if [[ "$update_response" == "Y" || "$update_response" == "y" || "$update_response" == "" ]]; then
  if [ -f app/etc/env.php ]; then
    sed -i "s/'dbname' => '.*'/'dbname' => '$dbname'/g" app/etc/env.php
    echo "app/etc/env.php was updated with the new database name."
  else
    echo "app/etc/env.php does not exist in the current directory."
  fi
else
  echo "Skipping update of app/etc/env.php."
fi

echo ""
echo "New database - $dbname"
