# Docker Setup Guide

This repository contains Docker configurations for various PHP versions.

## Usage Guide

### 1. Configure Hosts File

Ensure you add the domain name to your host file.

Example:
```
127.0.0.1 website.local
```

### 2. Update Configuration Files

In your `docker-compose.yml` file:

```yaml
services: 
    <project-name>:
        user: <name>
        domain: <your domain>
    volumes:
        - ./<project-folder-name>:/var/www/html/
    ports:
        - "8201:80"
        - "8000:443"
```

Ensure ports are unique and unused.

### 3. Run Docker Containers

Navigate to the directory containing your `docker-compose.yml` file in your terminal.

Run the following command:
```bash
docker-compose up --build
```

### Optional: Visual Studio Code Integration

Install the Docker extension for Visual Studio Code (`ms-azuretools.vscode-docker`).

In the Docker tab, right-click on the running container and select "Attach Visual Studio Code" to open the project inside Docker.

You should now have access to PHP and npm commands, ready for coding.

---

<center> Best wishes on your journey! 💛 </center>
