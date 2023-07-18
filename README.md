# odooDockerRepo
This is the source code for odoo docker server running on ubuntu AWS ec2 instance. The odoo server contain 3 container:
1.odoo (from image: odoo:16.0)
2.odoo_db (from image: postgres:15)
3.odoo_proxy (from image: nginx:latest)

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)

## prerequisites
To work with this repository, you will need to meet the following prerequisites (if the server is deployed with odooterraform script, git and docker has been pre installed ):

- **Git:** Git should be installed on your machine. Git is a version control system utilized for managing and tracking changes to the project's source code. You can install it by using the following command in your terminal:

```bash
sudo apt-get update
sudo apt-get install git
sudo git clone < repo URL >
```

- **Docker Engine:** Docker Engine should be installed on your machine. It allows you to create and manage Docker containers. Run this script to install docker engine :

```bash
cd get2knowOdoo
sudo ./installDocker.sh
```

## installation
run the folloing command to start the odoo server

```bash
cd get2knowOdoo
sudo docker compose up -d
```

## usage
to add new tenant run the following command :

```bash
sudo ./autoCreateCert.sh <domain> <email>
```
replace <domain> and <email> with tenant domain and email



## Configuration

This project runs Nginx in a Docker container, along with a Certbot and its Nginx plugin for SSL certificate management. Once an SSL certificate is obtained through Certbot, it will automatically renew before it expires.

### File Mappings

The configuration files for the Certbot, Nginx, and Odoo are stored outside the Docker container and are mapped into the container. This allows you to modify these configuration files without needing to directly access the container. The mapping is done as follows:

- Certbot configuration file is mapped to: `~/get2knowOdoo/config/certbot`
- Nginx configuration file is mapped to: `~/get2knowOdoo/config/nginx/default.conf`
- Odoo configuration file is mapped to: `~/get2knowOdoo/config/odoo/odoo.conf`

### Odoo Server Addon Folder

The Odoo server addon folder is mapped to a local directory. This allows for easy management of custom addons. The mapping is done to: `~/get2knowOdoo/odoo-custom-addons`

### Docker Volumes

In addition to the above mappings, Docker volumes have also been created to manage persistent data. These volumes can be seen under the `/var/lib/docker/volumes` directory.

