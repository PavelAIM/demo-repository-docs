# Export Markdown to DOCX

This repository includes tools to convert Markdown files to DOCX format for better sharing and collaboration.

## Quick Start

### Option 1: Using the provided script (Recommended)

1. **Install Pandoc** (if not already installed):
   ```bash
   # Ubuntu/Debian
   sudo apt install pandoc
   
   # macOS
   brew install pandoc
   
   # Windows
   # Download from https://pandoc.org/installing.html
   ```

2. **Run the converter script**:
   ```bash
   # Convert all .md files in the current directory
   ./convert-to-docx.sh
   
   # Convert a specific file
   ./convert-to-docx.sh openwebui_quickstart_upd.md
   ```

### Option 2: Manual Pandoc commands

```bash
# Convert a single file
pandoc openwebui_quickstart_upd.md -o openwebui_quickstart_upd.docx

# Convert with custom styling
pandoc openwebui_quickstart_upd.md -o openwebui_quickstart_upd.docx \
  --from markdown \
  --to docx \
  --reference-doc=template.docx  # Optional: use a custom template
```

### Option 3: Using Node.js (if you prefer JavaScript)

```bash
# Install markdown-to-docx
npm install -g markdown-to-docx

# Convert files
markdown-to-docx openwebui_quickstart_upd.md
```

## Features

The provided script (`convert-to-docx.sh`) includes:

- ✅ **Batch conversion** - Convert all .md files at once
- ✅ **Color-coded output** - Easy to see progress and errors
- ✅ **Error handling** - Continues processing even if some files fail
- ✅ **Progress tracking** - Shows success/error counts
- ✅ **Pandoc detection** - Checks if pandoc is installed

## Output

Converted files will be saved in the same directory with `.docx` extension:
- `openwebui_quickstart_upd.md` → `openwebui_quickstart_upd.docx`
- `complete-openwebui-guide.md` → `complete-openwebui-guide.docx`

## Customization

### Using a custom DOCX template

1. Create a reference document in Word with your desired styling
2. Save it as `template.docx`
3. Use the `--reference-doc` option:

```bash
pandoc input.md -o output.docx --reference-doc=template.docx
```

### Advanced Pandoc options

```bash
pandoc input.md -o output.docx \
  --from markdown \
  --to docx \
  --toc \                    # Add table of contents
  --number-sections \        # Number sections
  --highlight-style=tango    # Code highlighting style
```

## Troubleshooting

### Common issues:

1. **"Pandoc not found"** - Install pandoc using the commands above
2. **Images not showing** - Make sure image paths are relative to the markdown file
3. **Formatting issues** - Try using a reference document for consistent styling
4. **Large files** - Consider splitting very large documents

### Getting help:

```bash
# Check pandoc version
pandoc --version

# See all available options
pandoc --help

# Check supported formats
pandoc --list-input-formats
pandoc --list-output-formats
```

## Alternative Tools

If pandoc doesn't work for your needs, consider:

- **Typora** - WYSIWYG markdown editor with export
- **Obsidian** - Markdown editor with export plugins
- **VS Code** - Use extensions like "Markdown PDF" or "Markdown All in One"
- **Online converters** - Various web-based tools (less secure for sensitive content) 