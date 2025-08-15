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

## Organization Benefits

- **Root directory**: Clean, only essential scripts
- **Bin directory**: Archived scripts for reference/fallback
- **Clear separation**: Easy to understand what's current vs. archived
