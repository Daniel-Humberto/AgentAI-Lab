#!/usr/bin/env bash
# ==============================================================================
# Agentic Lab - DevOps & MLOps Orchestration Script
# OS Target: Ubuntu 24.04 LTS
# ==============================================================================

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ==========================================
# Funciones Utilitarias
# ==========================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ==========================================
# Verificaciones Previas e Instalación
# ==========================================
check_prerequisites() {
    log_info "Verificando prerrequisitos del sistema..."
    
    if ! command -v docker &> /dev/null; then
        log_warning "Docker no está instalado. Iniciando instalación automatizada..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        log_success "Docker instalado correctamente. (Puede requerir reiniciar sesión para aplicar permisos de grupo)"
    else
        log_success "Docker ya está instalado."
    fi

    if ! dpkg -l | grep -q nvidia-container-toolkit; then
        log_warning "NVIDIA Container Toolkit no detectado. Instalando..."
        curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
        sudo apt-get update
        sudo apt-get install -y nvidia-container-toolkit
        sudo nvidia-ctk runtime configure --runtime=docker
        sudo systemctl restart docker
        log_success "NVIDIA Container Toolkit configurado con éxito."
    else
        log_success "NVIDIA Container Toolkit ya está configurado."
    fi
}

init_env() {
    if [ ! -f .env ]; then
        log_warning "Archivo .env no encontrado. Copiando desde .env.example..."
        if [ -f .env.example ]; then
            cp .env.example .env
            log_success "Archivo .env creado. Por favor, revisa y edita las contraseñas si es necesario."
        else
            log_error "No se encontró .env.example en la raíz del proyecto."
        fi
    else
        log_success "Archivo .env verificado."
    fi
}

# ==========================================
# Gestión del Proyecto
# ==========================================
start_lab() {
    log_info "Iniciando infraestructura Agentic Lab (18 contenedores)..."
    docker compose up -d
    log_success "Laboratorio en línea. Monitoreo MLOps disponible en Grafana (Puerto 3001)."
}

stop_lab() {
    log_info "Deteniendo contenedores e infraestructura..."
    docker compose down
    log_success "Laboratorio detenido."
}

show_status() {
    log_info "Estado actual de los contenedores:"
    docker compose ps
}

show_help() {
    echo -e "Uso: $0 {install|start|stop|status|restart}"
    echo -e "  install  - Instala dependencias (Docker, NVIDIA Toolkit) e inicializa el .env"
    echo -e "  start    - Levanta todos los servicios con Docker Compose"
    echo -e "  stop     - Detiene y remueve los contenedores"
    echo -e "  status   - Muestra el estado de los contenedores"
    echo -e "  restart  - Reinicia la infraestructura (aplica cambios en compose)"
}

# ==========================================
# Punto de Entrada
# ==========================================
case "$1" in
    install)
        check_prerequisites
        init_env
        ;;
    start)
        init_env
        start_lab
        ;;
    stop)
        stop_lab
        ;;
    status)
        show_status
        ;;
    restart)
        stop_lab
        start_lab
        ;;
    *)
        show_help
        exit 1
        ;;
esac
