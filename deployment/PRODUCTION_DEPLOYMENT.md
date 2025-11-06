# 🚀 **PRODUCTION_DEPLOYMENT.md — Codebase Genius**

**Author:** Cavin Otieno
**Organization:** University of Nairobi
**Backend:** Supabase (PostgreSQL + Edge Functions + FastAPI)
**Frontend:** Streamlit Cloud / Vercel

---

## 🌍 **Overview**

This guide covers **all production deployment options** for the **Codebase Genius** project:

| Deployment Type         | Platform                | Description                              |
| ----------------------- | ----------------------- | ---------------------------------------- |
| **Backend API**         | Supabase Edge Functions | Python (FastAPI) backend with PostgreSQL |
| **Frontend (Option 1)** | Streamlit Cloud         | Deployed Streamlit dashboard             |
| **Frontend (Option 2)** | Vercel                  | React/Next.js web app for production use |

---

## 🧱 **1. Supabase Backend Deployment**

### 🔑 Project Configuration

| Property              | Value                                                                                                                                                                                                              |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Organization**      | Supabase                                                                                                                                                                                                           |
| **Project Name**      | `codebase-genius`                                                                                                                                                                                                  |
| **Project URL**       | `https://cieyycqrqtlzlmyvhqbn.supabase.co`                                                                                                                                                                         |
| **API Key**           | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpZXl5Y3FycXRsemxteXZocWJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNTAzMjgsImV4cCI6MjA3NzgyNjMyOH0.3TRUDiWHzANwwFyorQs1oPOAyP_QO22qZw9lmlCEfx4` |
| **Database Password** | `Airtel!23!23`                                                                                                                                                                                                     |
| **Dashboard**         | [https://supabase.com/dashboard](https://supabase.com/dashboard)                                                                                                                                                   |

---

### ⚙️ **Environment Variables**

Create a `.env` file or configure via Supabase Dashboard → **Project Settings → Configuration → Environment Variables**:

```bash
SUPABASE_URL=https://cieyycqrqtlzlmyvhqbn.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL=postgresql://postgres:Airtel!23!23@db.cieyycqrqtlzlmyvhqbn.supabase.co:5432/postgres
ENV=production
```

---

### 🧠 **Deploy FastAPI Function**

Ensure your function code exists at:
`supabase/functions/codebase-genius-api/main.py`

Then run:

```bash
supabase login
supabase link --project-ref cieyycqrqtlzlmyvhqbn
supabase functions deploy codebase-genius-api --project-ref cieyycqrqtlzlmyvhqbn
```

✅ **Production Endpoint:**

```
https://cieyycqrqtlzlmyvhqbn.supabase.co/functions/v1/codebase-genius-api
```

Test locally before deployment:

```bash
supabase start
supabase functions serve codebase-genius-api
```

---

## 🧩 **2. Streamlit Production Deployment**

### 🌐 Production URLs

* [https://oumacavin-codebase-genius-streamlit-app-mfk2u6.streamlit.app/](https://oumacavin-codebase-genius-streamlit-app-mfk2u6.streamlit.app/)
* (Optional) [https://codebase-genius.streamlit.app/](https://codebase-genius.streamlit.app/)

---

### ⚙️ **Streamlit Cloud Secrets**

In your Streamlit Cloud Dashboard → **Settings → Secrets** add:

```
SUPABASE_URL = "https://cieyycqrqtlzlmyvhqbn.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
DATABASE_URL = "postgresql://postgres:Airtel!23!23@db.cieyycqrqtlzlmyvhqbn.supabase.co:5432/postgres"
```

---

### 🚀 **Deployment Workflow**

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally for testing
streamlit run streamlit_app.py

# Push updates to GitHub
git add .
git commit -m "Update Streamlit production configuration"
git push origin main
```

Streamlit Cloud will automatically rebuild and redeploy your app upon push to `main`.

---

### ✅ **Architecture Overview**

```
Streamlit UI
   │
   ▼
Supabase Edge Function (FastAPI)
   │
   ▼
Supabase PostgreSQL Database
```

---

## 🌐 **3. Vercel Frontend Deployment (React / Next.js)**

This option is ideal for a scalable web interface version of your project.

---

### 🧱 **Vercel Setup**

1. Visit [https://vercel.com/new](https://vercel.com/new)
2. Connect your GitHub repository (`codebase-genius`)
3. Select the **main branch**
4. Vercel auto-detects React/Next.js and builds automatically.

---

### ⚙️ **Add Environment Variables**

In Vercel → **Project → Settings → Environment Variables**, add:

| Key                             | Value                                                                       |
| ------------------------------- | --------------------------------------------------------------------------- |
| `NEXT_PUBLIC_SUPABASE_URL`      | `https://cieyycqrqtlzlmyvhqbn.supabase.co`                                  |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | (Your anon key)                                                             |
| `API_BASE_URL`                  | `https://cieyycqrqtlzlmyvhqbn.supabase.co/functions/v1/codebase-genius-api` |

---

### 🚀 **Deploy**

After setting environment variables, click **Deploy**.

Vercel automatically builds and hosts your production app at:

```
https://<your-vercel-project>.vercel.app
```

---

### 🧠 **Verification**

* **Backend check:**

  ```
  https://cieyycqrqtlzlmyvhqbn.supabase.co/functions/v1/codebase-genius-api/health
  ```

* **Frontend check:**
  Test API calls in browser console or directly in UI.

---

## 🧾 **Deployment Recap**

| Component               | Platform               | Deployment Method           | URL                                                                                    |
| ----------------------- | ---------------------- | --------------------------- | -------------------------------------------------------------------------------------- |
| **Backend (API)**       | Supabase Edge Function | `supabase functions deploy` | [View API](https://cieyycqrqtlzlmyvhqbn.supabase.co/functions/v1/codebase-genius-api)  |
| **Frontend (Option 1)** | Streamlit Cloud        | Auto-deploy via Git push    | [Streamlit App](https://oumacavin-codebase-genius-streamlit-app-mfk2u6.streamlit.app/) |
| **Frontend (Option 2)** | Vercel                 | Auto-deploy via Git push    | `https://<your-vercel-project>.vercel.app`                                             |
| **Database**            | Supabase               | Managed PostgreSQL          | [Supabase Dashboard](https://supabase.com/dashboard)                                   |

---

## 🧩 **Optional: Local Debugging Before Deploy**

```bash
# Start Supabase locally
supabase start

# Serve your function locally
supabase functions serve codebase-genius-api

# Run your frontend locally
npm run dev   # or streamlit run streamlit_app.py
```

Then visit:

```
http://127.0.0.1:54321/functions/v1/codebase-genius-api
```

---

## 🧠 **Maintenance & Monitoring**

| Platform            | What to Monitor                         |
| ------------------- | --------------------------------------- |
| **Supabase**        | Database health, logs, function metrics |
| **Streamlit Cloud** | Error logs and environment secrets      |
| **Vercel**          | Build logs, deployments, uptime         |

---

## 🎯 **Summary**

Once complete:

✅ Your **backend (Supabase Edge Function)** is live
✅ Your **frontend (Streamlit or Vercel)** is deployed
✅ Your **database** runs securely in Supabase Cloud
✅ Changes to `main` automatically trigger redeploys

