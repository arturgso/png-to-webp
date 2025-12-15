#!/bin/bash

# Configuração
LOG_FILE="/tmp/webp_conversion_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="/tmp/webp_errors_$(date +%Y%m%d_%H%M%S).log"

# Função para registrar logs
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRO: $1" | tee -a "$LOG_FILE" >> "$ERROR_LOG"
}

# Iniciar logs
log_message "=== Início da conversão PNG para WebP ==="
log_message "Diretório de origem: ${1:-.}"
log_message "Diretório de destino: ${2:-./webp_output}"

# Verifica se o cwebp está instalado
if ! command -v cwebp &> /dev/null; then
    log_error "cwebp não está instalado."
    log_error "Instale com: sudo apt install webp (Ubuntu/Debian)"
    exit 1
fi

# Diretório atual ou fornecido como argumento
SRC_DIR="${1:-.}"

# Diretório de destino para WebP (padrão: webp_output)
DEST_DIR="${2:-./webp_output}"

# Criar diretório de destino se não existir
if ! mkdir -p "$DEST_DIR" 2>> "$ERROR_LOG"; then
    log_error "Falha ao criar diretório de destino: $DEST_DIR"
    exit 1
fi

# Contadores
converted=0
failed=0
moved=0

log_message "Criando diretório de destino: $DEST_DIR"

# 1. Primeiro, mover WebP existentes
log_message "Movendo WebP existentes..."
for webp_file in "$SRC_DIR"/*.[wW][eE][bB][pP]; do
    [ -f "$webp_file" ] || continue

    if mv -f "$webp_file" "$DEST_DIR/" 2>> "$ERROR_LOG"; then
        log_message "Movido: $(basename "$webp_file")"
        ((moved++))
    else
        log_error "Falha ao mover: $(basename "$webp_file")"
    fi
done

# 2. Converter PNG para WebP
log_message "Iniciando conversão de PNG para WebP..."
for png_file in "$SRC_DIR"/*.[pP][nN][gG]; do
    # Verifica se o glob encontrou algum arquivo
    [ -f "$png_file" ] || continue

    # Nome base do arquivo (sem extensão)
    filename=$(basename "$png_file" | sed 's/\.[pP][nN][gG]$//')

    # Nome do arquivo de saída no diretório de destino
    webp_file="$DEST_DIR/${filename}.webp"

    log_message "Convertendo: $(basename "$png_file") -> ${filename}.webp"

    # Converte para WebP removendo metadados (-metadata none)
    # Usando -quiet para suprimir a saída detalhada e redirecionando stderr para o arquivo de erros
    if cwebp -quiet -metadata none "$png_file" -o "$webp_file" 2>> "$ERROR_LOG"; then
        log_message "Sucesso: ${filename}.webp"
        ((converted++))
    else
        log_error "Falha na conversão: $(basename "$png_file")"
        # Remover arquivo de saída corrompido, se existir
        [ -f "$webp_file" ] && rm -f "$webp_file" 2>> "$ERROR_LOG"
        ((failed++))
    fi
done

# Resumo final
echo "==========================================" | tee -a "$LOG_FILE"
echo "CONVERSÃO CONCLUÍDA - RESUMO" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Diretório origem: $SRC_DIR" | tee -a "$LOG_FILE"
echo "Diretório destino: $DEST_DIR" | tee -a "$LOG_FILE"
echo "Arquivos WebP movidos: $moved" | tee -a "$LOG_FILE"
echo "Arquivos PNG convertidos: $converted" | tee -a "$LOG_FILE"
echo "Arquivos com falha: $failed" | tee -a "$LOG_FILE"
echo "Total de arquivos WebP: $(find "$DEST_DIR" -name "*.webp" -o -name "*.WEBP" 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
echo "------------------------------------------" | tee -a "$LOG_FILE"
echo "Logs gerados em:" | tee -a "$LOG_FILE"
echo "  - Log completo: $LOG_FILE" | tee -a "$LOG_FILE"
echo "  - Apenas erros: $ERROR_LOG" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"

# Verificar se há erros
if [ -s "$ERROR_LOG" ]; then
    echo "AVISO: Foram encontrados erros. Verifique $ERROR_LOG"
    echo "Últimos erros:"
    tail -5 "$ERROR_LOG"
fi
