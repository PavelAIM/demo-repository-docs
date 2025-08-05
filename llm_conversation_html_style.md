# 🤖 Chat with LLM: Chat-Bubble Style (HTML Enhanced)

## 🧩 Topic: Formatting LLM Conversations in Markdown  
**Date:** 2025-07-29  
**Purpose:** Simulate real chat layout using HTML inside Markdown.

---

## ✨ Alternative 1.1: Chat-Like Style with HTML

<div style="text-align: right; background-color: #e6f7ff; padding: 10px; border-radius: 10px; margin: 10px 0;">
<b>User:</b><br>
How can I convert a PDF to text in Python?
</div>

<div style="text-align: left; background-color: #f6f6f6; padding: 10px; border-radius: 10px; margin: 10px 0;">
<b>Assistant:</b><br>
You can use libraries like <code>PyPDF2</code>, <code>pdfminer.six</code>, or <code>PyMuPDF</code>. Here's an example using PyPDF2:
<pre><code>import PyPDF2
with open('file.pdf', 'rb') as f:
    reader = PyPDF2.PdfReader(f)
    text = ''.join(page.extract_text() for page in reader.pages)
print(text)
</code></pre>
</div>

<div style="text-align: right; background-color: #e6f7ff; padding: 10px; border-radius: 10px; margin: 10px 0;">
<b>User:</b><br>
Can I also extract images?
</div>

<div style="text-align: left; background-color: #f6f6f6; padding: 10px; border-radius: 10px; margin: 10px 0;">
<b>Assistant:</b><br>
PyPDF2 doesn’t support image extraction well. Try <code>PyMuPDF</code> (<code>fitz</code>) instead.
</div>

---

## 🔍 Note

This style uses inline HTML, so it will only render properly in Markdown viewers that allow raw HTML (like Obsidian, VS Code with preview plugins, or static site generators).

