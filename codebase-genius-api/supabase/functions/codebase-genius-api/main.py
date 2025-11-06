"""
Supabase Edge Function for Codebase Genius
Main entry point for all API routes
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# Ensure imports work correctly
sys.path.insert(0, os.path.dirname(__file__))

from routes import app as fastapi_app  # updated relative import

# Configure CORS (safe for public frontend calls)
fastapi_app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# This is the main entrypoint for Supabase
app = fastapi_app
