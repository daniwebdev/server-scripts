#!/bin/bash
# setup_server.sh - A script to set up a server with Nginx, PHP 8.3, and Composer.

# Purpose:
# This script automates the following tasks:
# 1. Creates a working directory structure.
# 2. Updates and upgrades the system packages.
# 3. Installs Nginx, PHP 8.3, and required PHP extensions.
# 4. Adds the Sury repository for PHP 8.3.
# 5. Installs Composer (PHP dependency manager).
# 6. Displays installed versions of Composer and PHP.

# Usage:
# Run this script with sudo privileges:
#   sudo bash setup_server.sh

# Exit script if any command fails
set -e

# === Functions ===
# Function to print a message with formatting
print_message() {
    echo -e "\n\033[1;32m$1\033[0m\n"
}

# === Script ===

# 1. Create and set up the working directory
print_message "Creating and configuring /workdir directory..."
sudo mkdir -p /workdir
sudo chown $USER -R /workdir/
cd /workdir || exit 1

# Create subdirectories
mkdir -p config logs apps

# 2. Update and upgrade the system
print_message "Updating and upgrading system packages..."
sudo apt update
sudo apt list --upgradable
sudo apt upgrade -y

# 3. Install Nginx, PHP 8.3, and required extensions
print_message "Installing Nginx, PHP 8.3, and PHP extensions..."
sudo apt install -y nginx php8.3-fpm php8.3-dom php8.3-pgsql php8.3-zip

# 4. Install necessary dependencies for adding repositories
print_message "Installing dependencies for repositories..."
sudo apt install -y software-properties-common ca-certificates lsb-release apt-transport-https gnupg2

# 5. Add Sury repository for PHP 8.3
print_message "Adding Sury PHP repository..."
sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -

# Update package list again
print_message "Updating package lists after adding Sury repository..."
sudo apt update

# 6. Reinstall PHP 8.3 (from Sury repository)
print_message "Reinstalling PHP 8.3 and its extensions..."
sudo apt install -y nginx php8.3-fpm php8.3-dom php8.3-pgsql php8.3-zip

# 7. Install Composer
print_message "Installing Composer (PHP dependency manager)..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Verify installer integrity
EXPECTED_SIGNATURE="dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" = "$ACTUAL_SIGNATURE" ]; then
    echo "Composer installer verified successfully."
else
    echo "Composer installer verification failed!"
    rm composer-setup.php
    exit 1
fi

# Run Composer setup
php composer-setup.php
php -r "unlink('composer-setup.php');"

# Move Composer to a global location
sudo mv composer.phar /usr/bin/composer

# 8. Verify installations
print_message "Verifying Composer and PHP installations..."
composer -v
php -v

# Final message
print_message "Server setup is complete! Nginx, PHP 8.3, and Composer are ready."
