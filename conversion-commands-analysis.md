# Conversion Commands Analysis

## Overview
This document analyzes the conversion commands and scripts used to transform Markdown files to DOCX format in this repository.

## File Pairs Identified

Based on the repository analysis, the following file pairs represent export/transformation results:

| Markdown File | DOCX File | Created Date | Purpose |
|---------------|-----------|--------------|---------|
| `1-2-4-https-caddy-keycloak.md` | `1-2-4-https-caddy-keycloak.docx` | Aug 7, 2025 | OAuth/HTTPS/Caddy guide export |
| `openwebui_quickstart_upd.md` | `openwebui_quickstart_upd.docx` | Multiple dates | Main guide export |
| `openwui-no-caddy-version.md` | `openwui-no-caddy-version.docx` | Aug 15, 2025 | Clean version export |
| `openwebui_quickstart_upd_temp.md` | `openwebui_quickstart_upd copy.docx` | Aug 5, 2025 | Temporary version export |

## Conversion Scripts Available

### 1. `convert-to-docx.sh` (Primary Converter)
**Created**: Commit `cf9069f` (Aug 5, 2025)
**Purpose**: Main Markdown to DOCX converter with image support

**Key Command Structure**:
```bash
pandoc "$input_file" \
    -o "$output_file" \
    --from markdown \
    --to docx \
    --extract-media="$media_dir" \
    --standalone \
    --wrap=none
```

**Usage**:
```bash
# Convert all markdown files
./convert-to-docx.sh

# Convert specific file
./convert-to-docx.sh 1-2-4-https-caddy-keycloak.md
```

### 2. `simple-convert.sh` (Alternative Converter)
**Created**: Commit `903126c` (Aug 5, 2025)
**Purpose**: Two-step conversion via HTML for better image handling

**Key Command Structure**:
```bash
# Step 1: Markdown → HTML
pandoc "$input_file" \
    -o "$html_file" \
    --from markdown \
    --to html \
    --standalone \
    --embed-resources

# Step 2: HTML → DOCX
pandoc "$html_file" \
    -o "$output_file" \
    --from html \
    --to docx
```

**Usage**:
```bash
# Convert all markdown files
./simple-convert.sh

# Convert specific file
./simple-convert.sh 1-2-4-https-caddy-keycloak.md
```

### 3. `convert-with-images.sh` (Advanced Converter)
**Created**: Commit `cf9069f` (Aug 5, 2025)
**Purpose**: Advanced image processing and conversion

## When Each Conversion Was Used

### August 7, 2025 - First Major Conversion
**Commit**: `af1452a`
**Files Created**: 
- `1-2-4-https-caddy-keycloak.md` (new article)
- `1-2-4-https-caddy-keycloak.docx` (exported version)

**Likely Command Used**:
```bash
./convert-to-docx.sh 1-2-4-https-caddy-keycloak.md
```

**Why This Script**: The `convert-to-docx.sh` script was available at this time and provides the best image handling for technical documentation.

### August 15, 2025 - Article Split and Conversion
**Commit**: `c221730`
**Files Created**:
- `openwui-no-caddy-version.md` (new clean version)
- `openwui-no-caddy-version.docx` (exported version)

**Likely Command Used**:
```bash
./convert-to-docx.sh openwui-no-caddy-version.md
```

## Manual Conversion Commands

### Direct Pandoc Usage
```bash
# Basic conversion
pandoc 1-2-4-https-caddy-keycloak.md -o 1-2-4-https-caddy-keycloak.docx

# With custom template
pandoc 1-2-4-https-caddy-keycloak.md -o 1-2-4-https-caddy-keycloak.docx \
    --reference-doc=template.docx

# With image extraction
pandoc 1-2-4-https-caddy-keycloak.md -o 1-2-4-https-caddy-keycloak.docx \
    --extract-media=media_folder
```

### Alternative Tools
```bash
# Using markdown-to-docx (Node.js)
npm install -g markdown-to-docx
markdown-to-docx 1-2-4-https-caddy-keycloak.md

# Using LibreOffice (if available)
libreoffice --headless --convert-to docx 1-2-4-https-caddy-keycloak.md
```

## Conversion Workflow

### Typical Process
1. **Write/Edit** markdown file
2. **Test** formatting and images
3. **Convert** to DOCX using appropriate script
4. **Review** exported document
5. **Commit** both markdown and DOCX versions

### Why Both Versions Are Kept
1. **Markdown**: Source format, version controlled, easy to edit
2. **DOCX**: Distribution format, better for non-technical users, preserves formatting

## Recommendations

### For Future Conversions
1. **Use `convert-to-docx.sh`** for most conversions (best image support)
2. **Use `simple-convert.sh`** if image issues occur
3. **Always test** conversion with images before committing
4. **Keep both versions** in repository for different use cases

### Script Improvements
1. **Add version tracking** to conversion scripts
2. **Include conversion metadata** in output files
3. **Add batch processing** for multiple files
4. **Include error recovery** for failed conversions

## Conclusion

The conversion commands used were:
- **Primary**: `./convert-to-docx.sh <filename.md>`
- **Alternative**: `./simple-convert.sh <filename.md>`
- **Manual**: `pandoc <input.md> -o <output.docx>`

These scripts were created specifically for this repository's documentation needs and provide robust conversion with image support, making them ideal for technical documentation that includes screenshots and diagrams.
