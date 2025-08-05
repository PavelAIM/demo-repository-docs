#!/bin/bash

# ============================================
# Markdown to DOCX Converter
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

# Convert single file with image handling
convert_file() {
    local input_file="$1"
    local output_file="${input_file%.md}.docx"
    local media_dir="${input_file%.md}_media"
    
    print_step "Конвертирую: $input_file → $output_file"
    
    # Create media directory for extracted images
    mkdir -p "$media_dir"
    
    # Convert with image extraction and proper handling
    if pandoc "$input_file" \
        -o "$output_file" \
        --from markdown \
        --to docx \
        --extract-media="$media_dir" \
        --standalone \
        --wrap=none \
        --reference-doc="" \
        --data-dir=""; then
        
        print_success "Файл создан: $output_file"
        
        # Check if images were extracted
        if [ -d "$media_dir" ] && [ "$(ls -A "$media_dir" 2>/dev/null)" ]; then
            print_success "Изображения извлечены в: $media_dir"
        else
            print_warning "Изображения не найдены или не извлечены"
        fi
        
        # Clean up empty media directory
        if [ -d "$media_dir" ] && [ -z "$(ls -A "$media_dir" 2>/dev/null)" ]; then
            rmdir "$media_dir"
        fi
        
    else
        print_error "Ошибка при конвертации: $input_file"
        return 1
    fi
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
    echo -e "${BLUE}║      Markdown → DOCX Converter          ║${NC}"
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