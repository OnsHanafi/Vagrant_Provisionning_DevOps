# Automated DevOps Tools Provisioning with Vagrant

This repository contains scripts and configuration files to automate the provisioning of essential DevOps tools using Vagrant. With a single command, you can set up Jenkins, SonarQube, Nexus, and a monitoring stack (Grafana and Prometheus) on virtual machines.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Tools Provisioned](#tools-provisioned)
- [Setup Instructions](#setup-instructions)


---

## Overview

This project simplifies the deployment and testing of popular DevOps tools by automating the provisioning process with Vagrant. Each tool is installed and configured using dedicated scripts, ensuring consistency and repeatability.

---

## Prerequisites

Before you start, make sure you have the following installed:

- [Vagrant](https://www.vagrantup.com/) (2.3 or later)
- [VirtualBox](https://www.virtualbox.org/) or any supported Vagrant provider
- [Git](https://git-scm.com/) (for cloning the repository)
- A stable internet connection to download dependencies during provisioning

---

## Tools Provisioned

1. **Jenkins**: A powerful tool for automating CI/CD pipelines.  
   Script: `jenkins.sh`

2. **SonarQube**: A platform for code quality and security analysis.  
   Script: `sonarqube.sh`

3. **Nexus**: An artifact repository manager to store and manage build artifacts.  
   Script: `nexus.sh`

4. **Monitoring Stack**:  
   - **Prometheus**: Collects and stores metrics for monitoring.  
   - **Grafana**: Visualizes metrics with custom dashboards.  
   Script: `monitoring.sh`

---

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/OnsHanafi/Vagrant_Provisionning_DevOps.git
   cd Vagrant_Provisionning_DevOps
2. Start the provisionning process
  ```bash
   vagrant init
   vagrant up 
    
    
