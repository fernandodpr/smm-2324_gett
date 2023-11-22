# How to containerize an HTTPS server
## Introduction

Dockerizing an HTTPS server involves encapsulating the web server application along with its dependencies in a Docker container. Here I show a guide on how to dockerize an HTTPS server using Nginx as an example.

> [!NOTE] 
> Make sure you have Docker installed on your system before you begin.

## 1. Create the working directory
```bash
mkdir my_https_server
cd my_https_server
```
## 2. Create the Dockerfile
In the directory you just created, create the Dockerfile file (`nano Dockerfile`) with the following content:

```Dockerfile
# Use a base image with HTTPS support, such as nginx:alpine
FROM nginx:alpine

# Copy the necessary configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY cert.pem /etc/nginx/cert.pem
COPY key.pem /etc/nginx/key.pem

# Expose port 443 for HTTPS
EXPOSE 443
```

## 3. Create the nginx.conf
Create the nginx.conf file (`nano nginx`) in the same directory as the Dockerfile and write:
```nginx
user  nginx;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/cert.pem;
        ssl_certificate_key /etc/nginx/key.pem;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
    }
}

```
## 4. Create the SSL certificates if you don't have them
Create them in the same directory as the Dockerfile with the following commands:

`openssl genpkey -algorithm RSA -out key.pem`

`openssl req -new -key key.pem -x509 -days 365 -out cert.pem`

> [!IMPORTANT] 
> It is important to put the name of the server (in this case localhost) in the "Common Name" field when creating cert.pem

If you do not want to have the certificates in the same directory, change the following lines in the Dockerfile:
```Dockerfile
COPY /path-to-cert/cert.pem /etc/nginx/cert.pem
COPY /path-to-key/key.pem /etc/nginx/key.pem
```
And the same for any file or folder that you want to place inside your container.

## 5. Setting our application
We download and unzip the html folder of our application (shared on Drive) in the same directory as the Dockerfile.

## 6. Launch the app
We are going to use the commands from the *Docker commands* section (#7).
Once commands [#7.1](#7.1) and [#7.2](#7.2) have been executed, we can see our server by entering the route https://localhost/. Specifically, to see our app we will navigate to https://localhost/encriptado/testplayerenc.html.

Every time we want to make a change in the Dockerfile, that is, in the application, we will have to stop and delete the container with the commands [#7.3](#7.3) and [#7.4](#7.4), and once the changes are made changes we make the first ones again.

## 7. Docker commands(#7)
### Build the image [#7.1](#7.1)
`docker build -t smm-c .`

*smm-c* is the name given to the image. 

### Container execution [#7.2](#7.2)
`docker run -d -p 443:443 --name smm-c-container smm-c`

*smm-c-container* is the name given to the container.

### Stop the container [#7.3](#7.3)
`docker stop smm-c-container`

### Delete the container [#7.4](#7.4)
`docker rm smm-c-container`
