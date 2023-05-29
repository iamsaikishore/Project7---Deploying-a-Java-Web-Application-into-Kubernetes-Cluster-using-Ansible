# Project7---Deploying-a-Java-Web-Application-into-Kubernetes-Cluster-using-Ansible

![project](https://github.com/iamsaikishore/Project7---Deploying-a-Java-Web-Application-into-Kubernetes-Cluster-using-Ansible/assets/129657174/5b3ec818-0b56-4ea3-9277-a2422b8a3d2f)

Here is a description of the project:

This project will deploy a Java web application to Kubernetes using Ansible. The project will use the following tools:

Jenkins: Jenkins is a continuous integration and continuous delivery (CI/CD) server. It will be used to automate the build, test, and deploy of the Java web application.

Maven: Maven is a build automation tool. It will be used to build the Java web application.

Ansible: Ansible is an IT automation tool. It will be used to deploy the Java web application to Kubernetes.

Sonarqube: Sonarqube is a code quality management tool. It will be used to analyze the Java web application for quality issues.

Docker: Docker is a containerization platform. It will be used to package the Java web application into Docker containers.

Kubernetes: Kubernetes is a container orchestration platform. It will be used to deploy and manage the Docker containers.

Nginx: Nginx is a web server. It will be used as a reverse proxy for the Jenkins, Sonarqube, and Kubernetes servers.

SSL: SSL is a security protocol that encrypts data transmitted over the internet. It will be used to secure the communication between the Jenkins, Sonarqube, and Kubernetes servers and the users.

Build the Java web application using Maven, will be analyzed for quality issues using Sonarqube, will be packaged into Docker containers using Docker, Push the Docker image to a Docker registry, will be deployed to Kubernetes using Ansible, Nginx will be configured as a reverse proxy for the Jenkins, Sonarqube, and Kubernetes servers and SSL will be used to secure the communication between the servers and the users.

Once the project is complete, the Java web application will be deployed to Kubernetes and will be accessible to users via a secure connection.

## Server Configurations

![server](https://github.com/iamsaikishore/Project7---Deploying-a-Java-Web-Application-into-Kubernetes-Cluster-using-Ansible/assets/129657174/25ae2281-dc7e-4a64-9139-70081ad03e50)

Configuring Server-1 (Jenkins-Ansible Server)

Operating System     : Ubuntu
Hostname             : jenkins-ansible
RAM                  : 2 GB
CPU                  : 1 Core
EC2 Instance         : t2.small

Update repository of Ubuntu

sudo -i
sudo apt-get update

Change time zone

date
timedatectl
sudo timedatectl set-timezone Asia/Kolkata
timedatectl
date

Change hostname

hostname
hostnamectl set-hostname jenkins-ansible

Installing Java:

sudo su -
apt update -y
apt-get install openjdk-11-jdk -y
java -version

Installing Jenkins:

First, add the repository key to your system:

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

The gpg --dearmor command is used to convert the key into a format that apt recognizes.

Next, let’s append the Debian package repository address to the server’s sources.list:

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

The [signed-by=/usr/share/keyrings/jenkins.asc] portion of the line ensures that apt will verify files in the repository using the GPG key that you just downloaded.

After both commands have been entered, run apt update so that apt will use the new repository.

sudo apt-get update -y

Finally, install Jenkins and its dependencies:

sudo apt-get install jenkins -y

Now that Jenkins and its dependencies are in place, we’ll start the Jenkins server.

sudo systemctl enable jenkins.service
sudo systemctl start jenkins.service
sudo systemctl status jenkins.service

Ansible

Ansible® is an open source IT automation tool that automates provisioning, configuration management, application deployment, orchestration, and many other manual IT processes. Unlike more simplistic management tools, Ansible users (like system administrators, developers and architects) can use Ansible automation to install software, automate daily tasks, provision infrastructure, improve security and compliance, patch systems, and share automation across the entire organization.

Install Python

sudo apt update -y
sudo apt install python3 python3-pip -y

Installing Ansible:

sudo apt update -y
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

Installing Maven:

cd /opt/
ls
wget https://dlcdn.apache.org/maven/maven-3/3.9.1/binaries/apache-maven-3.9.1-bin.zip
apt-get install unzip -y
unzip apache-maven-3.9.1-bin.zip
ls
rm -rf apache-maven-3.9.1-bin.zip
ls

Configure maven home path

vim ~/.bashrc

## Add end of the file & save it.
export M2_HOME=/opt/apache-maven-3.9.1
export PATH=$PATH:$M2_HOME/bin

source ~/.bashrc

Check version
Bash

mvn --version
mvn --help

Installing Nginx:

apt update -y
apt install nginx -y

systemctl start nginx
systemctl enable nginx
systemctl status nginx

Navigate to nginx configuration directory and delete the server details from the nginx.conf file. The edited nginx.conf file should look like the below image.

Now navigate to /etc/nginx/conf.d and create jenkins.conf file and copy the below content, edit the configuration and save the jenkins.conf file.

```
upstream jenkins {
  keepalive 32; # keepalive connections
  server 127.0.0.1:8080; # jenkins ip and port
}

# Required for Jenkins websocket agents
map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen          80;       # Listen on port 80 for IPv4 requests

  server_name     jenkins.example.com;  # replace 'jenkins.example.com' with your server domain name

  # this is the jenkins web root directory
  # (mentioned in the output of "systemctl cat jenkins")
  root            /var/run/jenkins/war/;

  access_log      /var/log/nginx/jenkins.access.log;
  error_log       /var/log/nginx/jenkins.error.log;

  # pass through headers from Jenkins that Nginx considers invalid
  ignore_invalid_headers off;

  location ~ "^/static/[0-9a-fA-F]{8}\/(.*)$" {
    # rewrite all static files into requests to the root
    # E.g /static/12345678/css/something.css will become /css/something.css
    rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /$1 last;
  }

  location /userContent {
    # have nginx handle all the static requests to userContent folder
    # note : This is the $JENKINS_HOME dir
    root /var/lib/jenkins/;
    if (!-f $request_filename){
      # this file does not exist, might be a directory or a /**view** url
      rewrite (.*) /$1 last;
      break;
    }
    sendfile on;
  }

  location / {
      sendfile off;
      proxy_pass         http://jenkins;
      proxy_redirect     default;
      proxy_http_version 1.1;

      # Required for Jenkins websocket agents
      proxy_set_header   Connection        $connection_upgrade;
      proxy_set_header   Upgrade           $http_upgrade;

      proxy_set_header   Host              $http_host;
      proxy_set_header   X-Real-IP         $remote_addr;
      proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Proto $scheme;
      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_buffering            off;
      proxy_request_buffering    off; # Required for HTTP CLI commands
      proxy_set_header Connection ""; # Clear for keepalive
  }

}
```

Change server_name jenkins.example.com; to server_name jenkins.kishq.co

where 'kishq.co' is my domain

Change root /var/run/jenkins/war/; to root /var/cache/jenkins/war/;

nginx -t
nginx -s reload

use nginx -T to see nginx configuration

Now go to any browser and search "jenkins.your_domain" e.x: "jenkins.kishq.co"

Install Certbot:

apt update -y
apt install certbot python3-certbot-nginx -y
systemctl status certbot.timer
certbot renew --dry-run
certbot --nginx

Configuring Server-2 (Sonar Server)

Operating System     : Ubuntu
Hostname             : sonarqube
RAM                  : 2 GB
CPU                  : 1 Core
EC2 Instance         : t2.small

Update repository of Ubuntu

sudo -i
sudo apt-get update

Change time zone

date
timedatectl
sudo timedatectl set-timezone Asia/Kolkata
timedatectl
date

Change hostname

hostname
hostnamectl set-hostname sonarqube

Installing Java:

sudo su -
apt update -y
apt-get install openjdk-17-jdk -y       ## For sonarqube-10.0.0.68432.zip
apt-get install openjdk-11-jdk -y       ## For sonarqube-8.9.2.46101.zip
java -version         

Installing SonarQube:

cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.0.0.68432.zip
OR
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.2.46101.zip
apt install unzip -y
unzip sonarqube-10.0.0.68432.zip
ls
rm -rf sonarqube-10.0.0.68432.zip
mv sonarqube-10.0.0.68432 sonarqube
ls

Create sonar user

useradd -d /opt/sonarqube sonar
cat /etc/passwd | grep sonar
ls -ld /opt/sonarqube
chown -R sonar:sonar /opt/sonarqube
ls -ld /opt/sonarqube

Create custom service for sonar

cat >> /etc/systemd/system/sonarqube.service <<EOL
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking
User=sonar
Group=sonar
PermissionsStartOnly=true
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start 
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
StandardOutput=syslog
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=5
Restart=always

[Install]
WantedBy=multi-user.target
EOL


ls -l /etc/systemd/system/sonarqube.service

Service start

systemctl start sonarqube.service
   
Service start

systemctl start sonarqube.service
                                                   
Check 9000 port is used or not

apt install net-tools
netstat -plant | grep 9000

Open sonarqube on browser

URL:   http://<sonarqube_ip>:9000

U: admin
P: admin

New Pass: admin@123                                                   

                                                   
                                                   
                                                   
