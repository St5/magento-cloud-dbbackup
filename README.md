# Magento Cloud Database Backup

This script (`dbackup.sh`) is designed to automate the process of creating backups for Magento Cloud databases on your local machine. 
Its primary function is to facilitate quick updates of your local database from a specified environment.

## Features

- Downloads a database dump from Magento Cloud.
- Moves the dump file to a specified storage directory.
- Unzips the dump file.
- Checks if the database already exists and offers to delete it.
- Creates a new database.
- Imports the database dump into the new database.
- Offers to delete the dump file after import.
- Offers to update `app/etc/env.php` with the new database name.

## Download/Update

```shellscript
wget -O dbackup.sh https://raw.githubusercontent.com/St5/magento-cloud-dbbackup/main/dbackup.sh
```

## Usage

The script should be placed in the root directory of your project. 
It is executed with one argument, the environment (`env`), like so:

```shellscript
./dbackup.sh <env>
```
Please replace <env> with the name of the environment you want to use. 
For example, if you have an environment named production, you would run the script as follows:
```shellscript
./dbackup.sh staging
```

If you have correctly set up your local configuration in `app/etc/env.php` (like `base_url` etc.), then after the script finishes, you will only need to run `bin/magento setup:upgrade` to use the new database.

## Configuration
The script uses the following configurations:  

- `DumpDir`: The directory where the dump file will be stored.
- `dbuser`: The username for the database.
- `dbpass`: The password for the database.
- `host`: The host for the database.

These configurations are set at the top of the script and can be modified as needed.  

## Requirements

- Magento Cloud CLI: The script uses the `magento-cloud` command to download the database dump.
- MySQL: The script uses the `mysql` command to interact with the database.
- Gunzip: The script uses the `gunzip` command to unzip the database dump.

## Note

The script will prompt for user input in certain situations, such as when the database already exists or when deciding whether to delete the dump file after import. Please be ready to provide input when running the script.
