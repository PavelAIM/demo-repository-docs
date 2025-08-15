# Bin Directory - Archived Scripts

This directory contains conversion scripts that are no longer the primary choice for markdown to DOCX conversion.

## Scripts Moved Here

### `convert-to-docx.sh`
- **Purpose**: Basic Markdown to DOCX converter
- **Status**: Archived - limited image support
- **Why moved**: `simple-convert.sh` provides better image handling

### `convert-with-images.sh`
- **Purpose**: Advanced image processing converter
- **Status**: Archived - complex, not needed for basic use
- **Why moved**: `simple-convert.sh` is simpler and more reliable

## DOCX Files Moved Here

### `1-2-4-https-caddy-keycloak.docx`
- **Source**: `1-2-4-https-caddy-keycloak.md`
- **Size**: 16.8 KB
- **Status**: Recreatable from markdown source

### `openwebui_quickstart_upd copy.docx`
- **Source**: `openwebui_quickstart_upd_temp.md`
- **Size**: 8.8 MB
- **Status**: Recreatable from markdown source

### `openwebui-no-caddy-version.docx`
- **Source**: `openwebui-no-caddy-version.md`
- **Size**: 8.8 MB
- **Status**: Recreatable from markdown source

### `test_doc_output.docx`
- **Source**: Test conversion output
- **Size**: 8.8 MB
- **Status**: Recreatable from markdown source

## Current Recommendation

**Use `simple-convert.sh` in the root directory** - it's the ONLY script that properly handles images/pictures in markdown files.

## If You Need These Scripts

You can still use them by running from the bin directory:
```bash
./bin/convert-to-docx.sh <filename.md>
./bin/convert-with-images.sh <filename.md>
```

But for files with images, always prefer:
```bash
./simple-convert.sh <filename.md>
```

## Recreating DOCX Files

If you need to recreate any of the DOCX files, use the source markdown files in the root directory:

```bash
# For files with images (recommended)
./simple-convert.sh 1-2-4-https-caddy-keycloak.md
./simple-convert.sh openwebui-no-caddy-version.md

# For text-only files
./bin/convert-to-docx.sh openwebui_quickstart_upd.md
```

## Organization Benefits

- **Root directory**: Clean, only essential scripts and source markdown files
- **Bin directory**: Archived scripts and generated DOCX files for reference/fallback
- **Clear separation**: Easy to understand what's current vs. archived vs. generated
- **Source control**: Only markdown files are version controlled, DOCX files are recreatable
