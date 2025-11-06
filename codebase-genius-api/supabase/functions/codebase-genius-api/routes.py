"""
Enhanced API Routes with Real AI Agent Integration
Supports both synchronous (quick) and asynchronous (webhook) modes
"""

import os
import asyncio
import json
import traceback
import tempfile
import zipfile
import logging
import uuid
import shutil
import aiohttp
import re
import subprocess
from typing import Dict, List, Optional, Any
from fastapi import FastAPI, HTTPException, BackgroundTasks, Header
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel
import sys

# Add agents to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'agents'))

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Try importing real agents
try:
    from agents.supervisor_agent.main import SupervisorAgent
    from agents.repository_mapper.main import RepositoryMapperAgent
    from agents.code_analyzer.main import CodeAnalyzerAgent
    from agents.docgenie_agent.main import DocGenieAgent
    AGENTS_AVAILABLE = True
    logger.info("Real AI agents imported successfully")
except Exception as e:
    AGENTS_AVAILABLE = False
    logger.warning(f"Real agents not available, using simulation mode: {e}")

# Request Models
class RepositoryRequest(BaseModel):
    repository_url: str
    branch: Optional[str] = "main"
    analysis_depth: Optional[str] = "full"
    include_diagrams: Optional[bool] = True
    format: Optional[str] = "markdown"
    mode: Optional[str] = "auto"  # "auto", "quick", "full", "webhook"
    webhook_url: Optional[str] = None  # For async processing

class WorkflowStatus(BaseModel):
    workflow_id: str
    status: str
    progress: float
    current_step: str
    result: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None
    mode: Optional[str] = "quick"

# API Response Models
class APIResponse(BaseModel):
    success: bool
    data: Optional[Any] = None
    error: Optional[str] = None
    timestamp: str

class WorkflowResponse(BaseModel):
    workflow_id: str
    status: str
    message: str
    estimated_completion: Optional[int] = None
    mode: str = "quick"

# Workflow Manager
class WorkflowManager:
    def __init__(self):
        self.active_workflows: Dict[str, Dict[str, Any]] = {}
        self.completed_workflows: Dict[str, Dict[str, Any]] = {}
        
    def create_workflow(self, request: RepositoryRequest) -> str:
        """Create a new analysis workflow"""
        workflow_id = str(uuid.uuid4())
        
        self.active_workflows[workflow_id] = {
            'request': request,
            'status': 'pending',
            'progress': 0.0,
            'current_step': 'Initializing',
            'created_at': asyncio.get_event_loop().time(),
            'result': None,
            'error_message': None,
            'estimated_completion': 300,
            'mode': request.mode or "auto"
        }
        
        logger.info(f"Created workflow {workflow_id} for {request.repository_url}")
        return workflow_id
        
    def update_workflow(self, workflow_id: str, status: str, progress: float, 
                       current_step: str, result: Optional[Dict] = None, 
                       error_message: Optional[str] = None):
        """Update workflow status"""
        if workflow_id in self.active_workflows:
            self.active_workflows[workflow_id].update({
                'status': status,
                'progress': progress,
                'current_step': current_step,
                'result': result,
                'error_message': error_message
            })
            
            if status in ['completed', 'failed']:
                self.completed_workflows[workflow_id] = self.active_workflows.pop(workflow_id)
                
    def get_workflow_status(self, workflow_id: str) -> Optional[Dict[str, Any]]:
        """Get workflow status"""
        return (self.active_workflows.get(workflow_id) or 
                self.completed_workflows.get(workflow_id))
                
    def list_workflows(self) -> List[str]:
        """List all workflow IDs"""
        return list(self.active_workflows.keys()) + list(self.completed_workflows.keys())

# Global workflow manager
workflow_manager = WorkflowManager()

# Main FastAPI Application
app = FastAPI(
    title="Codebase Genius API",
    description="Multi-agent codebase documentation generation system",
    version="2.0.0"
)

# Utility Functions
async def validate_repository_url(url: str) -> bool:
    """Validate repository URL format and accessibility"""
    patterns = [
        r'^https?://github\.com/[^/]+/[^/]+/?$',
        r'^https?://gitlab\.com/[^/]+/[^/]+/?$',
        r'^https?://bitbucket\.org/[^/]+/[^/]+/?$',
    ]
    
    if not any(re.match(pattern, url) for pattern in patterns):
        return False
        
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(url, timeout=aiohttp.ClientTimeout(total=5)) as response:
                return response.status == 200
    except Exception as e:
        logger.warning(f"Repository accessibility check failed: {e}")
        return False

def estimate_repository_size(url: str) -> str:
    """Estimate repository size to choose processing mode"""
    # Simple heuristic based on repository URL
    # In production, you'd query GitHub API
    return "small"  # small, medium, large

async def generate_documentation_full_agents(workflow_id: str, request: RepositoryRequest):
    """Generate documentation using actual AI agents"""
    try:
        workflow_manager.update_workflow(
            workflow_id, "running", 0.05, "Initializing AI agents"
        )
        
        # Initialize agents
        supervisor = SupervisorAgent()
        mapper = RepositoryMapperAgent()
        analyzer = CodeAnalyzerAgent()
        docgenie = DocGenieAgent()
        
        workflow_manager.update_workflow(
            workflow_id, "running", 0.1, "Validating repository"
        )
        
        # Validate repository
        is_valid = await validate_repository_url(request.repository_url)
        if not is_valid:
            raise Exception("Repository URL is invalid or inaccessible")
            
        workflow_manager.update_workflow(
            workflow_id, "running", 0.2, "Cloning repository"
        )
        
        # Step 1: Repository Mapping
        mapper.repository_url = request.repository_url
        clone_result = mapper.clone_repository(request.repository_url)
        
        if "error" in clone_result:
            raise Exception(f"Clone failed: {clone_result['error']}")
            
        clone_path = clone_result.get('clone_path')
        
        workflow_manager.update_workflow(
            workflow_id, "running", 0.4, "Mapping repository structure"
        )
        
        # Generate file tree
        file_tree = mapper.generate_file_tree(clone_path)
        repository_info = {
            'url': request.repository_url,
            'clone_path': clone_path,
            'file_tree': file_tree,
            'stats': clone_result.get('repository_info', {})
        }
        
        workflow_manager.update_workflow(
            workflow_id, "running", 0.5, "Analyzing code structure"
        )
        
        # Step 2: Code Analysis
        analyzer.repository_path = clone_path
        analyzer.analysis_depth = request.analysis_depth
        
        # Parse code files
        code_analysis = analyzer.analyze_repository(clone_path)
        
        workflow_manager.update_workflow(
            workflow_id, "running", 0.7, "Generating documentation"
        )
        
        # Step 3: Documentation Generation
        docgenie.repository_info = repository_info
        docgenie.ccg_data = code_analysis
        docgenie.config.diagram_enabled = request.include_diagrams
        
        # Generate documentation
        documentation = docgenie.generate_documentation()
        
        workflow_manager.update_workflow(
            workflow_id, "running", 0.9, "Finalizing output"
        )
        
        # Create output package
        output_dir = f"/tmp/{workflow_id}"
        os.makedirs(output_dir, exist_ok=True)
        
        # Save documentation
        doc_file = os.path.join(output_dir, f"documentation.{request.format}")
        with open(doc_file, 'w', encoding='utf-8') as f:
            f.write(documentation.get('content', ''))
            
        # Create ZIP
        zip_path = os.path.join(output_dir, "documentation.zip")
        with zipfile.ZipFile(zip_path, 'w') as zipf:
            zipf.write(doc_file, f"documentation.{request.format}")
            zipf.writestr("metadata.json", json.dumps(documentation.get('metadata', {}), indent=2))
            
        # Cleanup clone
        if clone_path and os.path.exists(clone_path):
            shutil.rmtree(clone_path, ignore_errors=True)
            
        # Update workflow
        workflow_manager.update_workflow(
            workflow_id, "completed", 1.0, "Documentation generated successfully",
            result={
                'documentation': documentation,
                'repository_info': repository_info,
                'download_url': f"/api/download/{workflow_id}",
                'output_directory': output_dir
            }
        )
        
    except Exception as e:
        logger.error(f"Full agent workflow {workflow_id} failed: {str(e)}")
        logger.error(traceback.format_exc())
        workflow_manager.update_workflow(
            workflow_id, "failed", 0.0, "Generation failed",
            error_message=str(e)
        )

async def generate_documentation_quick(workflow_id: str, request: RepositoryRequest):
    """Quick documentation generation (simplified, fits in 10s timeout)"""
    try:
        workflow_manager.update_workflow(
            workflow_id, "running", 0.1, "Validating repository"
        )
        
        is_valid = await validate_repository_url(request.repository_url)
        if not is_valid:
            raise Exception("Repository URL is invalid or inaccessible")
            
        workflow_manager.update_workflow(
            workflow_id, "running", 0.3, "Fetching repository info"
        )
        
        # Quick analysis without full clone
        with tempfile.TemporaryDirectory() as temp_dir:
            # Shallow clone
            subprocess.run([
                "git", "clone", "--depth", "1", "--single-branch",
                request.repository_url, temp_dir
            ], check=True, capture_output=True, timeout=5)
            
            workflow_manager.update_workflow(
                workflow_id, "running", 0.6, "Analyzing structure"
            )
            
            # Quick file analysis
            files = []
            for root, dirs, filenames in os.walk(temp_dir):
                dirs[:] = [d for d in dirs if not d.startswith('.')]
                for filename in filenames:
                    if not filename.startswith('.'):
                        file_path = os.path.join(root, filename)
                        rel_path = os.path.relpath(file_path, temp_dir)
                        files.append({
                            'path': rel_path,
                            'size': os.path.getsize(file_path)
                        })
            
            workflow_manager.update_workflow(
                workflow_id, "running", 0.9, "Generating documentation"
            )
            
            # Quick documentation
            doc_content = f"""# Repository Documentation

## Overview
Repository: {request.repository_url}
Total Files: {len(files)}
Analysis Date: {asyncio.get_event_loop().time()}

## Files
"""
            for f in files[:20]:  # First 20 files
                doc_content += f"- {f['path']} ({f['size']} bytes)\n"
                
            # Save output
            output_dir = f"/tmp/{workflow_id}"
            os.makedirs(output_dir, exist_ok=True)
            
            doc_file = os.path.join(output_dir, f"documentation.{request.format}")
            with open(doc_file, 'w', encoding='utf-8') as f:
                f.write(doc_content)
                
            zip_path = os.path.join(output_dir, "documentation.zip")
            with zipfile.ZipFile(zip_path, 'w') as zipf:
                zipf.write(doc_file, f"documentation.{request.format}")
                
            workflow_manager.update_workflow(
                workflow_id, "completed", 1.0, "Quick documentation generated",
                result={
                    'documentation': {'content': doc_content},
                    'files': files,
                    'download_url': f"/api/download/{workflow_id}",
                    'output_directory': output_dir
                }
            )
            
    except Exception as e:
        logger.error(f"Quick workflow {workflow_id} failed: {str(e)}")
        workflow_manager.update_workflow(
            workflow_id, "failed", 0.0, "Generation failed",
            error_message=str(e)
        )

# API Endpoints

@app.get("/")
async def root():
    """API health check"""
    return APIResponse(
        success=True,
        data={
            "message": "Codebase Genius API is running",
            "version": "2.0.0",
            "agents_available": AGENTS_AVAILABLE
        },
        timestamp=str(asyncio.get_event_loop().time())
    )

@app.get("/health")
async def health_check():
    """Detailed health check"""
    return {
        "status": "healthy",
        "timestamp": str(asyncio.get_event_loop().time()),
        "active_workflows": len(workflow_manager.active_workflows),
        "completed_workflows": len(workflow_manager.completed_workflows),
        "agents_available": AGENTS_AVAILABLE,
        "mode": "full" if AGENTS_AVAILABLE else "quick"
    }

@app.post("/api/analyze", response_model=WorkflowResponse)
async def start_analysis(request: RepositoryRequest, background_tasks: BackgroundTasks):
    """Start repository analysis workflow"""
    try:
        # Determine processing mode
        mode = request.mode or "auto"
        if mode == "auto":
            # Auto-select based on agent availability and repository size
            repo_size = estimate_repository_size(request.repository_url)
            if AGENTS_AVAILABLE and repo_size in ["small", "medium"]:
                mode = "full"
            else:
                mode = "quick"
        
        workflow_id = workflow_manager.create_workflow(request)
        
        # Start background task
        if mode == "full" and AGENTS_AVAILABLE:
            background_tasks.add_task(generate_documentation_full_agents, workflow_id, request)
            estimated_time = 300
        else:
            background_tasks.add_task(generate_documentation_quick, workflow_id, request)
            estimated_time = 30
        
        return WorkflowResponse(
            workflow_id=workflow_id,
            status="started",
            message=f"Analysis workflow created in {mode} mode",
            estimated_completion=estimated_time,
            mode=mode
        )
        
    except Exception as e:
        logger.error(f"Failed to start analysis: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/status/{workflow_id}", response_model=WorkflowStatus)
async def get_workflow_status(workflow_id: str):
    """Get workflow status"""
    workflow = workflow_manager.get_workflow_status(workflow_id)
    
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
        
    return WorkflowStatus(
        workflow_id=workflow_id,
        status=workflow['status'],
        progress=workflow['progress'],
        current_step=workflow['current_step'],
        result=workflow.get('result'),
        error_message=workflow.get('error_message'),
        mode=workflow.get('mode', 'quick')
    )

@app.get("/api/workflows")
async def list_workflows():
    """List all workflows"""
    return {
        "active_workflows": list(workflow_manager.active_workflows.keys()),
        "completed_workflows": list(workflow_manager.completed_workflows.keys()),
        "total_active": len(workflow_manager.active_workflows),
        "total_completed": len(workflow_manager.completed_workflows),
        "agents_available": AGENTS_AVAILABLE
    }

@app.get("/api/download/{workflow_id}")
async def download_documentation(workflow_id: str):
    """Download generated documentation"""
    workflow = workflow_manager.get_workflow_status(workflow_id)
    
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
        
    if workflow['status'] != 'completed':
        raise HTTPException(status_code=400, detail="Workflow not completed yet")
        
    result = workflow.get('result', {})
    if 'output_directory' not in result:
        raise HTTPException(status_code=500, detail="Output directory not found")
        
    zip_path = os.path.join(result['output_directory'], "documentation.zip")
    
    if not os.path.exists(zip_path):
        raise HTTPException(status_code=500, detail="Documentation file not found")
        
    return FileResponse(
        path=zip_path,
        filename=f"codebase-documentation-{workflow_id}.zip",
        media_type='application/zip'
    )

@app.delete("/api/workflows/{workflow_id}")
async def delete_workflow(workflow_id: str):
    """Delete workflow and cleanup files"""
    workflow = workflow_manager.get_workflow_status(workflow_id)
    
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
        
    result = workflow.get('result', {})
    if 'output_directory' in result and os.path.exists(result['output_directory']):
        shutil.rmtree(result['output_directory'], ignore_errors=True)
        
    if workflow_id in workflow_manager.active_workflows:
        del workflow_manager.active_workflows[workflow_id]
    if workflow_id in workflow_manager.completed_workflows:
        del workflow_manager.completed_workflows[workflow_id]
        
    return {"message": f"Workflow {workflow_id} deleted successfully"}

@app.get("/api/config")
async def get_api_config():
    """Get API configuration"""
    return {
        "supported_formats": ["markdown", "html", "pdf"],
        "max_file_size": "100MB",
        "supported_repositories": ["GitHub", "GitLab", "Bitbucket"],
        "analysis_depth_options": ["basic", "full", "comprehensive"],
        "estimated_analysis_time": "30 seconds (quick) / 2-5 minutes (full)",
        "modes": ["auto", "quick", "full", "webhook"],
        "agents_available": AGENTS_AVAILABLE,
        "current_mode": "full" if AGENTS_AVAILABLE else "quick"
    }
