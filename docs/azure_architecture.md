# Azure Architecture

## Objective

Deploy the PostgreSQL platform into Azure while preserving the
database design, automation, backup, recovery, and monitoring
capabilities developed locally.

## Current Local Architecture

Windows
    ↓
WSL / Kali
    ↓
Docker
    ↓
PostgreSQL 16
    ↓
cloud_platform

## Target Azure Architecture

Azure
    ├── Compute / Application Layer
    ├── PostgreSQL Database Layer
    ├── Virtual Network
    ├── Monitoring
    ├── Backup / Recovery
    └── Secrets Management

## Design Goals

- Secure database connectivity
- Private networking where practical
- Automated backups
- Monitoring and alerting
- Infrastructure that can later be deployed with Terraform
- Separation of application and database responsibilities