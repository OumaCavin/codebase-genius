## 🧠 Codebase Genius — Local Deployment Guide

### 🧩 Overview

This document explains how to set up and run the **Codebase Genius** project locally using:

* **Python (FastAPI + Mangum)**
* **Supabase (local Docker stack for database + auth + functions)**
* **Vercel (optional deployment)**
* **Node.js + npm for CLI tools**

The process is fully automated via the provided `setup_codebase_genius.sh` script, but this guide explains the underlying steps and how to troubleshoot or customize them.

---

## 🚀 Quick Setup (Recommended)

Run the automated setup script:

```bash
chmod +x setup_codebase_genius.sh
./setup_codebase_genius.sh
```

This single command will:

1. Check and install prerequisites (Python, Node, Docker, etc.)
2. Clone or update the repository
3. Create a Python virtual environment
4. Install dependencies
5. Set up Supabase locally (with Docker)
6. Create and serve your Supabase Edge Function
7. Optionally prepare for deployment to Vercel

After completion, you’ll have a fully functional **local environment** for both your API and Supabase backend.

---

## 🧰 Manual Setup (Step-by-Step)

If you prefer to do it manually, here’s the expanded process the script automates.

### 1. Prerequisites

Ensure the following are installed:

* **Git**
* **Python 3.10+**
* **pip**
* **Node.js and npm**
* **Docker Desktop**
* **Supabase CLI**

> 💡 Check by running:
>
> ```bash
> git --version
> python3 --version
> node --version
> docker --version
> supabase --version
> ```

---

### 2. Clone the Repository

```bash
mkdir -p ~/GeniusBase
cd ~/GeniusBase
git clone https://github.com/<your-repo>/codebase-genius.git
cd codebase-genius
```

---

### 3. Set Up Python Environment

```bash
python3 -m venv code-env
source code-env/bin/activate
pip install --upgrade pip
pip install -r api/requirements.txt
```

---

### 4. Install Global Tools

```bash
npm install -g vercel
```

If Supabase CLI is missing:

```bash
mkdir -p ~/.supabase/bin
curl -L https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz -o supabase.tar.gz
tar -xzf supabase.tar.gz -C ~/.supabase/bin
chmod +x ~/.supabase/bin/supabase
echo 'export PATH="$HOME/.supabase/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

### 5. Initialize Supabase Project

```bash
mkdir -p codebase-genius-api
cd codebase-genius-api
supabase init
```

---

### 6. Create an Edge Function (Python)

```bash
supabase functions new codebase-genius-api --runtime python
```

Replace its contents with a FastAPI app:

```bash
nano supabase/functions/codebase-genius-api/main.py
```

```python
from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello from Codebase Genius API!"}

handler = Mangum(app)
```

Add requirements:

```bash
echo -e "fastapi\nmangum\nuvicorn" > supabase/functions/codebase-genius-api/requirements.txt
```

---

### 7. Copy API Code

If you already have a backend in `api/`:

```bash
cp -r ~/GeniusBase/codebase-genius/api/* ~/GeniusBase/codebase-genius/codebase-genius-api/supabase/functions/codebase-genius-api/
```

---

### 8. Start Local Supabase Stack

This spins up Docker containers for:

* Postgres database
* Auth
* Realtime
* Storage
* Edge runtime

```bash
supabase start
```

You’ll get output similar to:

```
Database URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

✅ Your Supabase instance is now running locally.

---

### 9. Serve Edge Function Locally

```bash
supabase functions serve codebase-genius-api
```

Your API is now available at:

```
http://127.0.0.1:54321/functions/v1/codebase-genius-api
```

---

### 10. (Optional) Prepare for Vercel Deployment

Create a `vercel.json` file at the root if missing:

```json
{
  "version": 2,
  "builds": [
    { "src": "api/main.py", "use": "@vercel/python" }
  ],
  "routes": [
    { "src": "/(.*)", "dest": "api/main.py" }
  ]
}
```

Then deploy:

```bash
vercel --prod
```

---

## 🧠 Verification Checklist

| Task                     | Command                                                        | Expected Output                                  |
| ------------------------ | -------------------------------------------------------------- | ------------------------------------------------ |
| Check Supabase status    | `docker ps`                                                    | Supabase containers running                      |
| Access Supabase Studio   | [http://localhost:54323](http://localhost:54323)               | Browser dashboard opens                          |
| Test Edge Function       | `curl http://127.0.0.1:54321/functions/v1/codebase-genius-api` | `{"message": "Hello from Codebase Genius API!"}` |
| Verify virtualenv active | `which python`                                                 | Points to `code-env/bin/python`                  |

---

## 🧹 Cleanup

To stop local Supabase:

```bash
supabase stop
```

To remove containers and data:

```bash
supabase stop --remove
```

To deactivate Python environment:

```bash
deactivate
```

---

## 🧭 Directory Structure

After setup, your project structure should look like this:

```
GeniusBase/
└── codebase-genius/
    ├── api/
    │   ├── main.py
    │   ├── routes.py
    │   └── requirements.txt
    ├── code-env/
    ├── codebase-genius-api/
    │   └── supabase/
    │       └── functions/
    │           └── codebase-genius-api/
    │               ├── main.py
    │               ├── requirements.txt
    │               ├── routes.py
    │               └── ...
    ├── vercel.json
    └── setup_codebase_genius.sh
```

