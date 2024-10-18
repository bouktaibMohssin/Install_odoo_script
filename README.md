# Odoo Installation Script for Ubuntu

This script automates the installation of Odoo on an Ubuntu system using a virtual environment. It creates a PostgreSQL user for Odoo, sets up a system user, and installs all necessary dependencies while avoiding manual configuration.

## Features
- Installs the specified version of Odoo (e.g., 17, 18) without user prompts.
- Creates a dedicated system user and PostgreSQL user for Odoo.
- Sets up a virtual environment for Python dependencies.
- Configures Odoo to run as a service using systemd.

## Prerequisites
- Ubuntu 20.04 or later.
- Sudo privileges to install packages and configure system services.

## How to Use

1. **Clone the Repository**:
    ```bash
   git clone https://github.com/yourusername/your-repo.git
   cd your-repo

2. **Make the Script Executable**:
   ```bash
   chmod +x install_odoo.sh
   
3. **Run the Script: Pass the desired Odoo version as an argument. For example, to install Odoo 17**:
   ```bash
   ./install_odoo.sh 17

4. **Access Odoo: Once the installation is complete, access Odoo via your web browser at**:
   ```bash
   http://localhost:10017  # For Odoo 17
   http://localhost:10018  # For Odoo 18

## Important Notes
- Ensure that your system is up to date before running the script.
- The default admin password for Odoo is set to "admin." Change it in the configuration file if needed.

## Troubleshooting
- If you encounter permission issues, ensure you run the script with `sudo`.
- Verify that all required packages are installed and up to date.
- Check the Odoo log files located at `/var/log/odoo<version>/odoo.log` for any errors during startup.

