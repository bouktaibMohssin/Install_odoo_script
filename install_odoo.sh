#!/bin/bash

# Check if the version argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <odoo_version>"
  exit 1
fi

ODOO_VERSION=$1
ODOO_PORT=$((10000 + ODOO_VERSION))

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt install git python3-pip build-essential wget python3-dev python3-venv \
    python3-wheel libfreetype6-dev libxml2-dev libzip-dev libldap2-dev libsasl2-dev \
    python3-setuptools node-less libjpeg-dev zlib1g-dev libpq-dev \
    libxslt1-dev libldap2-dev libtiff5-dev libjpeg8-dev libopenjp2-7-dev \
    liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev -y

# Install PostgreSQL
sudo apt install postgresql postgresql-server-dev-all -y

# Set up the PostgreSQL user for Odoo
sudo su - postgres -c "createuser -s odoo${ODOO_VERSION}"
sudo su - postgres -c "psql -c \"ALTER USER odoo${ODOO_VERSION} WITH PASSWORD 'odoo${ODOO_VERSION}';\""

# Create the Odoo system user using the useradd command
sudo useradd -m -d /opt/odoo${ODOO_VERSION} -U -r -s /bin/bash odoo${ODOO_VERSION}

# Create the Odoo directory
sudo mkdir -p /opt/odoo${ODOO_VERSION}
sudo chown -R odoo${ODOO_VERSION}: /opt/odoo${ODOO_VERSION}

# Switch to the Odoo user
sudo -u odoo${ODOO_VERSION} bash << EOF
# Create a virtual environment
python3 -m venv /opt/odoo${ODOO_VERSION}/odoo-venv

# Activate the virtual environment
source /opt/odoo${ODOO_VERSION}/odoo-venv/bin/activate

# Clone the specified Odoo version source code into /opt/odoo{version}/odoo
git clone https://www.github.com/odoo/odoo --depth 1 --branch ${ODOO_VERSION}.0 /opt/odoo${ODOO_VERSION}/odoo

# Install Python dependencies
pip install wheel
pip install -r /opt/odoo${ODOO_VERSION}/odoo/requirements.txt
EOF

# Create a configuration file for Odoo with dynamic port
sudo bash -c "cat <<EOF > /etc/odoo${ODOO_VERSION}.conf
[options]
   admin_passwd = admin
   db_host = False
   db_port = False
   db_user = odoo${ODOO_VERSION}
   db_password = odoo${ODOO_VERSION}
   addons_path = /opt/odoo${ODOO_VERSION}/odoo/addons
   logfile = /var/log/odoo${ODOO_VERSION}/odoo.log
   xmlrpc_port = ${ODOO_PORT}
EOF"

# Create the log directory
sudo mkdir -p /var/log/odoo${ODOO_VERSION}
sudo chown odoo${ODOO_VERSION}: /var/log/odoo${ODOO_VERSION}

# Adjust permissions on the configuration file
sudo chown odoo${ODOO_VERSION}: /etc/odoo${ODOO_VERSION}.conf
sudo chmod 640 /etc/odoo${ODOO_VERSION}.conf

# Setup Odoo systemd service
sudo bash -c "cat <<EOF > /etc/systemd/system/odoo${ODOO_VERSION}.service
[Unit]
Description=Odoo${ODOO_VERSION}
Documentation=http://www.odoo.com
[Service]
Type=simple
User=odoo${ODOO_VERSION}
ExecStart=/opt/odoo${ODOO_VERSION}/odoo-venv/bin/python3 /opt/odoo${ODOO_VERSION}/odoo/odoo-bin -c /etc/odoo${ODOO_VERSION}.conf
[Install]
WantedBy=multi-user.target
EOF"

# Reload systemd and enable the Odoo service
sudo systemctl daemon-reload
sudo systemctl enable odoo${ODOO_VERSION}.service

# Start the Odoo service
sudo systemctl start odoo${ODOO_VERSION}.service

echo "Odoo ${ODOO_VERSION} installation completed! Access it via http://localhost:${ODOO_PORT}"
