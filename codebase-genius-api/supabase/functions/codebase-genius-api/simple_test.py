"""
Simple test API for Vercel deployment
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="Codebase Genius Test")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Codebase Genius API is working!"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "message": "Test API running successfully"}

@app.get("/api/status")
def api_status():
    return {
        "status": "operational",
        "version": "1.0.0-test",
        "endpoints": ["/", "/health", "/api/status"]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
