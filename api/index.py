"""
Vercel Serverless API for Codebase Genius
Main entry point for all API routes
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from mangum import Mangum
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from api.routes import app as fastapi_app

# Configure CORS for Streamlit Cloud integration
fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for public demo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mangum handler for Vercel
handler = Mangum(fastapi_app, lifespan="off")

# Export for Vercel
def handler_wrapper(request: Request):
    return handler(request)
