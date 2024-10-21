#!/bin/bash

# Check for required arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <odoo_version>"
    exit 1
fi

ODDO_VERSION=$1
ODDO_DIR="/opt/odoo${ODDO_VERSION}"
PYTHON_VERSION="python3.10"  # Adjust to your desired Python version
PORT=$((10000 + ODDO_VERSION))  # Adjusting port according to version

# Update the package list and install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y openssh-server fail2ban python3-pip python3-dev \
    libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev \
    build-essential libssl-dev libffi-dev libmysqlclient-dev libpq-dev \
    libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev git curl \
    python3-venv python3.10-venv fontconfig libxrender1 \
    xfonts-75dpi xfonts-base

# Download and install wkhtmltopdf 0.12.6.1-2
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo apt install -f -y  # Fix any dependency issues

# Create a system user for Odoo
sudo useradd -m -d "$ODDO_DIR" -U -r -s /bin/bash "odoo${ODDO_VERSION}"

# Create a PostgreSQL user for Odoo
sudo -u postgres createuser --createdb --username postgres --pwprompt "odoo${ODDO_VERSION}"

# Install Odoo
sudo mkdir -p "$ODDO_DIR"
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch ${ODDO_VERSION}.0 "$ODDO_DIR/odoo"

# Set up a Python virtual environment
sudo python3.10 -m venv "$ODDO_DIR/odoo-venv"
sudo chown -R "odoo${ODDO_VERSION}":"odoo${ODDO_VERSION}" "$ODDO_DIR"
source "$ODDO_DIR/odoo-venv/bin/activate"

# Install Python dependencies
pip install wheel
pip install -r "$ODDO_DIR/odoo/requirements.txt"

# Create a configuration file for Odoo
sudo tee /etc/odoo.conf <<EOF
[options]
; This is the password that allows database operations:
admin_passwd = admin
db_host = False
db_port = False
db_user = odoo${ODDO_VERSION}
db_password = False
addons_path = ${ODDO_DIR}/odoo/addons
logfile = /var/log/odoo${ODDO_VERSION}/odoo.log
EOF

# Create a log directory
sudo mkdir -p /var/log/odoo${ODDO_VERSION}
sudo chown -R "odoo${ODDO_VERSION}":"odoo${ODDO_VERSION}" /var/log/odoo${ODDO_VERSION}

# Create a systemd service file for Odoo
sudo tee /etc/systemd/system/odoo${ODDO_VERSION}.service <<EOF
[Unit]
Description=Odoo
After=postgresql.service

[Service]
User=odoo${ODDO_VERSION}
ExecStart=${ODDO_DIR}/odoo-venv/bin/python ${ODDO_DIR}/odoo/odoo-bin -c /etc/odoo.conf --xmlrpc-port=${PORT}
Restart=always

[Install]
WantedBy=default.target
EOF

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Start Odoo service
sudo systemctl start odoo${ODDO_VERSION}
sudo systemctl enable odoo${ODDO_VERSION}

echo "Odoo ${ODDO_VERSION} installation complete!"

