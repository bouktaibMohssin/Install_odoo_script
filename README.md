Odoo Installation Script for Ubuntu
This script automates the installation of Odoo on an Ubuntu system using a virtual environment. It creates a PostgreSQL user for Odoo, sets up a system user, and installs all necessary dependencies while avoiding manual configuration.

Features
Installs the specified version of Odoo (e.g., 17, 18) without user prompts.
Creates a dedicated system user and PostgreSQL user for Odoo.
Sets up a virtual environment for Python dependencies.
Configures Odoo to run as a service using systemd.
Prerequisites
Ubuntu 20.04 or later.
Sudo privileges to install packages and configure system services.
How to Use
Clone the Repository:

bash
Copy code
git clone https://github.com/yourusername/your-repo.git
cd your-repo
Make the Script Executable:

bash
Copy code
chmod +x install_odoo.sh
Run the Script: Pass the desired Odoo version as an argument. For example, to install Odoo 17:

bash
Copy code
./install_odoo.sh 17
To install Odoo 18:

bash
Copy code
./install_odoo.sh 18
Access Odoo: Once the installation is complete, access Odoo via your web browser at:

bash
Copy code
http://localhost:10017  # For Odoo 17
http://localhost:10018  # For Odoo 18
Important Notes
Ensure that your system is up to date before running the script.
The default admin password for Odoo is set to "admin." Change it in the configuration file if needed.
