#!/bin/bash

# ============================================
# Markdown to DOCX Converter with Image Support
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

# Process images in markdown file
process_images() {
    local input_file="$1"
    local temp_file="${input_file%.md}_temp.md"
    
    print_step "Обработка изображений в файле..."
    
    # Copy original file
    cp "$input_file" "$temp_file"
    
    # Find and process image references
    local image_count=0
    while IFS= read -r line; do
        # Use grep to find image patterns instead of bash regex
        if echo "$line" | grep -q "!\[.*\](.*)"; then
            # Extract image path using sed
            local image_path=$(echo "$line" | sed -n 's/.*!\[.*\](\([^)]*\)).*/\1/p')
            if [ -n "$image_path" ]; then
                local image_name=$(basename "$image_path")
                
                # Check if image exists
                if [ -f "$image_path" ]; then
                    print_success "Найдено изображение: $image_name"
                    ((image_count++))
                else
                    print_warning "Изображение не найдено: $image_path"
                fi
            fi
        fi
    done < "$temp_file"
    
    if [ $image_count -gt 0 ]; then
        print_success "Обработано изображений: $image_count"
    else
        print_warning "Изображения не найдены"
    fi
    
    echo "$temp_file"
}

# Convert single file with enhanced image handling
convert_file() {
    local input_file="$1"
    local output_file="${input_file%.md}.docx"
    local media_dir="${input_file%.md}_media"
    
    print_step "Конвертирую: $input_file → $output_file"
    
    # Process images first
    local processed_file=$(process_images "$input_file")
    
    # Create media directory
    mkdir -p "$media_dir"
    
    # Try multiple conversion approaches for better image handling
    local success=false
    
    # Approach 1: Standard conversion with media extraction
    print_step "Попытка 1: Стандартная конвертация с извлечением медиа..."
    if pandoc "$processed_file" \
        -o "$output_file" \
        --from markdown \
        --to docx \
        --extract-media="$media_dir" \
        --standalone \
        --wrap=none; then
        success=true
        print_success "Конвертация успешна (подход 1)"
    else
        print_warning "Подход 1 не удался, пробуем подход 2..."
        
        # Approach 2: HTML intermediate conversion
        local html_file="${input_file%.md}.html"
        if pandoc "$processed_file" \
            -o "$html_file" \
            --from markdown \
            --to html \
            --standalone \
            --self-contained; then
            
            if pandoc "$html_file" \
                -o "$output_file" \
                --from html \
                --to docx \
                --extract-media="$media_dir"; then
                success=true
                print_success "Конвертация успешна (подход 2)"
            fi
            
            # Clean up HTML file
            rm -f "$html_file"
        fi
    fi
    
    if [ "$success" = true ]; then
        print_success "Файл создан: $output_file"
        
        # Check media directory
        if [ -d "$media_dir" ] && [ "$(ls -A "$media_dir" 2>/dev/null)" ]; then
            print_success "Медиафайлы извлечены в: $media_dir"
            echo "Содержимое медиа-директории:"
            ls -la "$media_dir"
        else
            print_warning "Медиафайлы не извлечены"
        fi
        
        # Clean up empty media directory
        if [ -d "$media_dir" ] && [ -z "$(ls -A "$media_dir" 2>/dev/null)" ]; then
            rmdir "$media_dir"
        fi
        
        # Clean up temp file
        if [ -f "$processed_file" ] && [ "$processed_file" != "$input_file" ]; then
            rm -f "$processed_file"
        fi
        
    else
        print_error "Все подходы к конвертации не удались: $input_file"
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
    echo -e "${BLUE}║   Markdown → DOCX (с поддержкой изображений) ║${NC}"
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