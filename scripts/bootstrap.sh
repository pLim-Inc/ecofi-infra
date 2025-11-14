#!/bin/bash
# Script de provisionamento para o ambiente de desenvolvimento EcosystemFi na Hetzner Cloud

set -e # Sai imediatamente se um comando falhar

echo "Iniciando provisionamento do ambiente EcosystemFi..."

# 1. Atualizar o sistema
echo "Atualizando pacotes do sistema..."
apt update && apt upgrade -y

# 2. Instalar pré-requisitos básicos
echo "Instalando ferramentas básicas..."
apt install -y curl wget git vim htop unzip build-essential ca-certificates gnupg lsb-release

# 3. Instalar Docker Engine
echo "Instalando Docker Engine..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Adiciona o repositório do Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza a lista de pacotes e instala o Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adiciona o usuário 'root' ao grupo 'docker' (não recomendado em produção, mas comum em servidores dedicados de dev)
usermod -aG docker root

# 4. Reiniciar o serviço Docker para garantir que as alterações de grupo sejam aplicadas
systemctl enable docker
systemctl start docker
# systemctl restart docker # Opcional, se quiser garantir que o daemon esteja completamente reiniciado

echo "Docker Engine instalado e iniciado."

# 5. Instalar Ubuntu Pro (ESM Apps/Infra) - ASSUMINDO QUE O TOKEN JÁ ESTÁ DISPONÍVEL
# Este passo assume que você já tem um token do Ubuntu Pro (gratuito para uso pessoal).
# Se você ainda não anexou, pode usar: sudo pro attach SEU_TOKEN_AQUI
# Para este script, verificamos se o 'pro' está instalado e anexado.
if ! command -v pro &> /dev/null; then
    echo "Instalando ubuntu-advantage-tools..."
    apt install -y ubuntu-advantage-tools
fi

# Verifica se já está anexado (pro status retorna 0 se estiver anexado)
if pro status | grep -q "attached"; then
   echo "Ubuntu Pro já está anexado."
else
   echo "Ubuntu Pro não está anexado. Por favor, anexe manualmente usando 'sudo pro attach SEU_TOKEN_AQUI' após o script."
   # Opcional: Solicitar o token como entrada (menos seguro via script, mas possível)
   # read -p "Insira seu token do Ubuntu Pro: " UBUNTU_PRO_TOKEN
   # pro attach $UBUNTU_PRO_TOKEN
fi

# 6. Verificar e aplicar patches de segurança do kernel (Livepatch), se disponível e anexado
if pro status --format json | jq -e '.services[] | select(.name=="livepatch").entitled' >/dev/null 2>&1; then
  if pro status --format json | jq -e '.services[] | select(.name=="livepatch").status' | grep -q "enabled"; then
     echo "Livepatch já está habilitado."
     # Opcional: Aplicar patch imediato
     # pro livepatch status # Mostra o status
     # pro livepatch update # Aplica o patch (não reinicia)
  else
     echo "Habilitando Livepatch..."
     pro enable livepatch
  fi
else
  echo "Livepatch não está disponível ou não está incluso na sua assinatura Ubuntu Pro atual."
fi


# 7. Criar diretório do projeto (se não existir)
PROJECT_DIR="/root/ecofi-dev"
if [ ! -d "$PROJECT_DIR" ]; then
  echo "Criando diretório do projeto em $PROJECT_DIR ..."
  mkdir -p $PROJECT_DIR
else
  echo "Diretório do projeto $PROJECT_DIR já existe."
fi

echo "Provisionamento básico concluído!"
echo ""
echo "Próximos passos:"
echo "1. Se ainda não anexou o Ubuntu Pro, execute: sudo pro attach SEU_TOKEN_AQUI"
echo "2. Clone o repositório do projeto: git clone https://github.com/pLim-Inc/ecofi-dev.git $PROJECT_DIR"
echo "3. Navegue até o diretório: cd $PROJECT_DIR"
echo "4. Inicie os serviços: docker compose up -d --build"
