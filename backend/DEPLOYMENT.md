# Server Setup Guide - CeyGo

## 1. Initial VPS Setup (Ubuntu 22.04 LTS)
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Setup Firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## 2. SSL Setup (Certbot)
```bash
sudo docker run -it --rm --name certbot \
  -v "/etc/letsencrypt:/etc/letsencrypt" \
  -v "/var/lib/letsencrypt:/var/lib/letsencrypt" \
  certbot/certbot certonly --manual \
  -d api.ceygo.lk
```

## 3. Database Backups
Add a cron job to backup the Postgres volume:
```bash
# Every day at 2 AM
0 2 * * * docker exec ceygo-db pg_dumpall -U ceygo_user > /backups/ceygo_$(date +\%F).sql
```

## 4. Monitoring
- **Health Check**: `https://api.ceygo.lk/api/v1/health`
- **Logs**: `docker compose logs -f backend`
