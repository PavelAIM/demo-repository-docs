# Manual Conversion with Images

If the automatic scripts don't work properly with images, try these manual approaches:

## Method 1: Using Pandoc with HTML Intermediate

```bash
# Step 1: Convert Markdown to HTML with embedded images
pandoc openwebui_quickstart_upd.md \
  -o temp.html \
  --from markdown \
  --to html \
  --standalone \
  --self-contained

# Step 2: Convert HTML to DOCX
pandoc temp.html \
  -o openwebui_quickstart_upd.docx \
  --from html \
  --to docx

# Step 3: Clean up
rm temp.html
```

## Method 2: Using Pandoc with Media Extraction

```bash
# Create a media directory
mkdir -p media

# Convert with media extraction
pandoc openwebui_quickstart_upd.md \
  -o openwebui_quickstart_upd.docx \
  --from markdown \
  --to docx \
  --extract-media=media \
  --standalone
```

## Method 3: Using Typora (GUI Tool)

1. Install Typora: https://typora.io/
2. Open your markdown file
3. Go to File → Export → Word (.docx)
4. Images will be automatically embedded

## Method 4: Using VS Code

1. Install the "Markdown All in One" extension
2. Open your markdown file
3. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
4. Type "Markdown All in One: Export to Word"
5. Select the output location

## Method 5: Using Online Converters

For non-sensitive content, you can use online converters:
- https://pandoc.org/try/
- https://www.markdowntopdf.com/
- https://word.aippt.com/

## Troubleshooting Images

### Check Image Paths
Make sure your images are referenced correctly:

```markdown
<!-- Correct -->
![Alt text](img/image.png)

<!-- Wrong -->
![Alt text](/absolute/path/image.png)
![Alt text](http://external-url.com/image.png)
```

### Convert Images to Base64 (if needed)
If images still don't work, you can embed them as base64:

```bash
# Install base64 encoder
# macOS: already available
# Ubuntu: sudo apt install base64

# Convert image to base64
base64 -i img/image.png | pbcopy  # macOS
base64 -i img/image.png | xclip -selection clipboard  # Linux
```

Then paste the base64 data in your markdown:
```markdown
![Alt text](data:image/png;base64,PASTE_BASE64_HERE)
```

### Use Relative Paths
Ensure all image paths are relative to the markdown file:

```markdown
<!-- If markdown is in root and images in img/ folder -->
![Alt text](img/image.png)

<!-- If markdown is in subfolder -->
![Alt text](../img/image.png)
```

## Best Practices

1. **Use relative paths** for all images
2. **Keep images in a subfolder** (like `img/`)
3. **Use common formats** (PNG, JPG, GIF)
4. **Optimize image sizes** (don't use huge images)
5. **Test with a small file first** before converting large documents 