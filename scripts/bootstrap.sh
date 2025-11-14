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

# Adiciona o usuário 'root' (ou o usuário atual, se não for root) ao grupo docker (opcional para segurança em outros contextos, mas comum em servidores dedicados)
# Para usuários não-root: usermod -aG docker $USER
usermod -aG docker root

# 4. Instalar Ubuntu Pro (ESM Apps/Infra) - ASSUMINDO QUE O TOKEN JÁ ESTÁ DISPONÍVEL
# Este passo assume que você já tem um token do Ubuntu Pro (gratuito para uso pessoal).
# Se ainda não anexou, pode usar: sudo pro attach SEU_TOKEN_AQUI
# O script abaixo verifica se o 'pro' está instalado e anexado.
if ! command -v pro &> /dev/null; then
    echo "Instalando ubuntu-advantage-tools..."
    apt install -y ubuntu-advantage-tools
fi

# Verifica se já está anexado (pro status retorna 0 se estiver anexado)
if pro status | grep -q "attached"; then
   echo "Ubuntu Pro já está anexado."
else
   echo "Ubuntu Pro NÃO está anexado. O script não pode anexar automaticamente sem o token."
   echo "Por favor, anexe manualmente após o script terminar: sudo pro attach C12iaVvonRJAWEyd78tz8seNo8sj6b"
   # Opcional: Solicitar o token como entrada (menos seguro via script, mas possível)
   # read -p "Insira seu token do Ubuntu Pro (ou pressione Enter para pular): " UBUNTU_PRO_TOKEN_INPUT
   # if [ -n "$UBUNTU_PRO_TOKEN_INPUT" ]; then
   #    pro attach $UBUNTU_PRO_TOKEN_INPUT
   # else
   #    echo "Nenhum token fornecido. Lembre-se de anexar manualmente."
   # fi
fi

# 5. Criar estrutura de diretórios para o projeto (exemplo)
echo "Criando estrutura de diretórios do projeto (exemplo)..."
mkdir -p ~/ecofi-dev/{identity-service,auth-service,asset-management-service,compliance-engine,period-closing-service}

echo "Provisionamento básico concluído!"
echo ""
echo "Lembre-se de:"
echo "  - Anexar o Ubuntu Pro com seu token (se ainda não feito): sudo pro attach C12iaVvonRJAWEyd78tz8seNo8sj6b"
echo "  - Clonar o repositório do projeto (se ainda não estiver no servidor):"
echo "    git clone https://github.com/pLim-Inc/ecofi-dev.git ~/ecofi-dev"
echo "  - Navegar para ~/ecofi-dev e iniciar os serviços:"
echo "    cd ~/ecofi-dev && docker compose up -d --build"
echo ""
echo "Lembre-se de anexar o Ubuntu Pro para manter o sistema seguro por até 10 anos (ESM)."
