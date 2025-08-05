#!/bin/bash

# ============================================
# Simple Markdown to DOCX Converter with Images
# ============================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if pandoc is installed
check_pandoc() {
    if ! command -v pandoc &> /dev/null; then
        print_error "Pandoc не установлен!"
        echo ""
        echo "Установите pandoc:"
        echo "  Ubuntu/Debian: sudo apt install pandoc"
        echo "  macOS: brew install pandoc"
        echo "  Windows: https://pandoc.org/installing.html"
        exit 1
    fi
    print_success "Pandoc найден: $(pandoc --version | head -1)"
}

# Convert single file using HTML intermediate method
convert_file() {
    local input_file="$1"
    local output_file="${input_file%.md}.docx"
    local html_file="${input_file%.md}_temp.html"
    
    print_step "Конвертирую: $input_file → $output_file"
    print_step "Использую метод HTML-промежуточного формата для лучшей поддержки изображений"
    
    # Step 1: Convert Markdown to HTML with embedded images
    print_step "Шаг 1: Конвертация в HTML с встроенными изображениями..."
    if pandoc "$input_file" \
        -o "$html_file" \
        --from markdown \
        --to html \
        --standalone \
        --embed-resources; then
        print_success "HTML файл создан: $html_file"
    else
        print_error "Ошибка при создании HTML файла"
        return 1
    fi
    
    # Step 2: Convert HTML to DOCX
    print_step "Шаг 2: Конвертация HTML в DOCX..."
    if pandoc "$html_file" \
        -o "$output_file" \
        --from html \
        --to docx; then
        print_success "DOCX файл создан: $output_file"
    else
        print_error "Ошибка при создании DOCX файла"
        # Clean up HTML file
        rm -f "$html_file"
        return 1
    fi
    
    # Step 3: Clean up temporary HTML file
    print_step "Очистка временных файлов..."
    rm -f "$html_file"
    print_success "Временные файлы удалены"
    
    print_success "Конвертация завершена успешно!"
    print_success "Файл готов: $output_file"
}

# Convert all markdown files
convert_all() {
    print_step "Поиск всех .md файлов..."
    local files=($(find . -name "*.md" -type f))
    
    if [ ${#files[@]} -eq 0 ]; then
        print_warning "Markdown файлы не найдены"
        return 1
    fi
    
    print_step "Найдено файлов: ${#files[@]}"
    
    local success_count=0
    local error_count=0
    
    for file in "${files[@]}"; do
        if convert_file "$file"; then
            ((success_count++))
        else
            ((error_count++))
        fi
    done
    
    echo ""
    echo -e "${GREEN}Успешно конвертировано: $success_count${NC}"
    if [ $error_count -gt 0 ]; then
        echo -e "${RED}Ошибок: $error_count${NC}"
    fi
}

# Main function
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Простой Markdown → DOCX Converter     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check pandoc
    check_pandoc
    
    # Check arguments
    if [ $# -eq 0 ]; then
        print_step "Конвертирую все .md файлы в текущей директории"
        convert_all
    elif [ $# -eq 1 ]; then
        if [ -f "$1" ]; then
            convert_file "$1"
        else
            print_error "Файл не найден: $1"
            exit 1
        fi
    else
        echo "Использование:"
        echo "  $0                    # Конвертировать все .md файлы"
        echo "  $0 file.md           # Конвертировать конкретный файл"
        exit 1
    fi
}

# Run main function
main "$@" 