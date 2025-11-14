#!/bin/bash
# Script de provisionamento para o ambiente de desenvolvimento EcosystemFi na Hetzner Cloud

set -e # Sai imediatamente se um comando falhar

echo "Iniciando provisionamento do ambiente de desenvolvimento EcosystemFi..."

# 1. Atualizar o sistema
echo "Atualizando o sistema..."
apt update && apt upgrade -y

# 2. Instalar pré-requisitos básicos
echo "Instalando ferramentas básicas..."
apt install -y curl wget git vim htop unzip build-essential ca-certificates gnupg lsb-release

# 3. Instalar Docker Engine
echo "Instalando Docker Engine..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adiciona o usuário atual (root) ao grupo docker (opcional para segurança em outros contextos)
# usermod -aG docker $USER

# 4. Instalar Ubuntu Pro (ESM Apps/Infra) - ASSUMINDO QUE O TOKEN JÁ ESTÁ DISPONÍVEL
# Este passo assume que você já tem um token do Ubuntu Pro (gratuito para uso pessoal).
# Substitua 'YOUR_UBUNTU_PRO_TOKEN' pelo seu token real ANTES de executar o script.
# echo "Anexando Ubuntu Pro..."
# pro attach YOUR_UBUNTU_PRO_TOKEN

# 5. Criar estrutura de diretórios para o projeto (exemplo)
echo "Criando estrutura de diretórios do projeto..."
mkdir -p ~/ecofi-dev/{identity-service,auth-service,asset-management-service,compliance-engine,period-closing-service}

# 6. (Opcional) Configurar Git (ajuste conforme seu nome e email do GitHub)
# git config --global user.name "Seu Nome"
# git config --global user.email "seu-email@exemplo.com"

echo "Provisionamento básico concluído!"
echo "Lembre-se de:"
echo "  - Anexar o Ubuntu Pro com seu token: sudo pro attach C12iaVvonRJAWEyd78tz8seNo8sj6b"
echo "  - Clonar o repositório do projeto: git clone https://github.com/pLim-Inc/ecofi-dev.git ~/ecofi-dev"
echo "  - Navegar para ~/ecofi-dev e iniciar os serviços: docker compose up -d --build"
