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

### 1. `simple-convert.sh` (Image-Compatible Converter) ⭐
**Location**: Root directory
**Created**: Commit `903126c` (Aug 5, 2025)
**Purpose**: **ONLY script that properly handles images/pictures in markdown files**

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

### 2. Archived Scripts (in `bin/` directory)
**Note**: These scripts have been moved to the `bin/` directory as they are no longer the primary choice:

- **`bin/convert-to-docx.sh`** - Basic converter with limited image support
- **`bin/convert-with-images.sh`** - Advanced converter (complex, not needed for basic use)

**Why archived**: `simple-convert.sh` provides better image handling and is simpler to use.



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
1. **Use `simple-convert.sh`** for files with images/pictures (ONLY script that works with images)
2. **Use archived scripts** in `bin/` directory only if needed for specific use cases
3. **Always test** conversion with images before committing
4. **Keep both versions** in repository for different use cases

### Script Improvements
1. **Add version tracking** to conversion scripts
2. **Include conversion metadata** in output files
3. **Add batch processing** for multiple files
4. **Include error recovery** for failed conversions

## Conclusion

The conversion commands used were:
- **For files WITH images**: `./simple-convert.sh <filename.md>` ⭐ (ONLY script that works with images)
- **For text-only files**: `./convert-to-docx.sh <filename.md>`
- **Manual**: `pandoc <input.md> -o <output.docx>`

**IMPORTANT**: `./simple-convert.sh` is the **ONLY** script that properly handles images/pictures in markdown files. Always use this script when converting documentation that contains screenshots, diagrams, or other images.
