# 🤖 Chat with LLM: Template & Comparison


## ✨ Alternative 1: Blockquote Style
---
> <div style="text-align: right;"><b>User: [💬]</b><br>  
> How can I convert a PDF to text in Python?</div>
---
>  **[📡] Assistant:**  
> You can use libraries like `PyPDF2`, `pdfminer.six`, or `PyMuPDF`. Here's an example using PyPDF2:
> 
> ```python
> import PyPDF2
> with open('file.pdf', 'rb') as f:
>     reader = PyPDF2.PdfReader(f)
>     text = ''.join(page.extract_text() for page in reader.pages)
> print(text)
> ```
---
> <div style="text-align: right;"><b>User:</b><br>  
> Can I also extract images?</div>
---
> **Assistant:**  
> PyPDF2 doesn't support image extraction well. Try `PyMuPDF` (`fitz`) instead.
---

