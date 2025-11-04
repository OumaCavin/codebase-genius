# Integrating AI Agents with the Live Demo

## Overview

This guide explains how to integrate the actual 4 AI agents (Repository Mapper, Code Analyzer, DocGenie, Supervisor) with the deployed live demo.

## Current Implementation

The current deployment includes a **simplified simulation** of the multi-agent system that:
- Validates and clones repositories
- Analyzes file structure
- Generates basic documentation
- Provides real-time progress tracking

## Full AI Agent Integration

To integrate the complete multi-agent system, follow these steps:

### Step 1: Agent Files Structure

The agents are located in `/workspace/deployment-package/agents/`:

```
agents/
├── repository-mapper/
│   ├── main.py
│   ├── requirements.txt
│   └── config/
├── code-analyzer/
│   ├── main.py
│   ├── requirements.txt
│   └── config/
├── docgenie-agent/
│   ├── main.py
│   ├── requirements.txt
│   └── config/
└── supervisor-agent/
    ├── main.py
    ├── requirements.txt
    └── config/
```

### Step 2: Update Backend Code

Replace the simplified `generate_documentation` function in `api/routes.py` with agent integration:

```python
async def generate_documentation(workflow_id: str, request: RepositoryRequest):
    """Generate documentation using the actual multi-agent system"""
    try:
        # Import agents
        from agents.supervisor_agent.main import SupervisorAgent
        from agents.repository_mapper.main import RepositoryMapperAgent
        from agents.code_analyzer.main import CodeAnalyzerAgent
        from agents.docgenie_agent.main import DocGenieAgent
        
        # Initialize supervisor
        supervisor = SupervisorAgent()
        
        # Initialize specialized agents
        mapper = RepositoryMapperAgent()
        analyzer = CodeAnalyzerAgent()
        docgenie = DocGenieAgent()
        
        # Register agents with supervisor
        supervisor.register_agent('mapper', mapper)
        supervisor.register_agent('analyzer', analyzer)
        supervisor.register_agent('docgenie', docgenie)
        
        # Update workflow status
        workflow_manager.update_workflow(
            workflow_id, "running", 0.1, "Initializing multi-agent system"
        )
        
        # Execute workflow through supervisor
        result = await supervisor.execute_workflow({
            'repository_url': request.repository_url,
            'branch': request.branch,
            'analysis_depth': request.analysis_depth,
            'include_diagrams': request.include_diagrams,
            'format': request.format,
            'workflow_id': workflow_id,
            'update_callback': lambda status, progress, step: 
                workflow_manager.update_workflow(workflow_id, status, progress, step)
        })
        
        # Update final workflow state
        workflow_manager.update_workflow(
            workflow_id, "completed", 1.0, "Documentation generated successfully",
            result=result
        )
        
    except Exception as e:
        logger.error(f"Workflow {workflow_id} failed: {str(e)}")
        workflow_manager.update_workflow(
            workflow_id, "failed", 0.0, "Generation failed",
            error_message=str(e)
        )
```

### Step 3: Update Requirements

Add agent dependencies to `requirements.txt`:

```txt
# Core API
fastapi==0.104.1
pydantic==2.5.0
aiohttp==3.9.1
mangum==0.17.0

# Agent Dependencies
tree-sitter==0.20.2
tree-sitter-python==0.20.4
tree-sitter-javascript==0.20.1
jinja2==3.1.2
markdown==3.5.1
graphviz==0.20.1
PyGithub==1.59.1
gitpython==3.1.40

# JAC Framework (if using .jac files)
# jac-lang==0.5.0  # Uncomment if needed
```

### Step 4: Agent Communication Protocol

Implement the agent communication protocol:

```python
# agents/base_agent.py
class BaseAgent:
    """Base class for all agents"""
    
    def __init__(self, name: str):
        self.name = name
        self.status = "idle"
        
    async def execute(self, task: Dict) -> Dict:
        """Execute agent task"""
        raise NotImplementedError
        
    async def update_status(self, status: str, progress: float):
        """Update agent status"""
        self.status = status
        # Send update to workflow manager

# agents/supervisor_agent.py
class SupervisorAgent(BaseAgent):
    """Orchestrates the entire workflow"""
    
    def __init__(self):
        super().__init__("Supervisor")
        self.agents = {}
        
    def register_agent(self, name: str, agent: BaseAgent):
        """Register a specialized agent"""
        self.agents[name] = agent
        
    async def execute_workflow(self, config: Dict) -> Dict:
        """Execute complete workflow"""
        
        # Step 1: Repository Mapping
        await self.update_progress("Repository mapping", 0.2)
        mapper_result = await self.agents['mapper'].execute({
            'repository_url': config['repository_url'],
            'branch': config['branch']
        })
        
        # Step 2: Code Analysis
        await self.update_progress("Code analysis", 0.5)
        analyzer_result = await self.agents['analyzer'].execute({
            'repository_data': mapper_result,
            'analysis_depth': config['analysis_depth']
        })
        
        # Step 3: Documentation Generation
        await self.update_progress("Documentation generation", 0.8)
        doc_result = await self.agents['docgenie'].execute({
            'analysis_data': analyzer_result,
            'include_diagrams': config['include_diagrams'],
            'format': config['format']
        })
        
        return doc_result
```

### Step 5: Deploy with Agents

#### Option A: Deploy as Separate Microservices

Deploy each agent as a separate Vercel function:

```
api/
├── index.py (main API)
├── agents/
│   ├── mapper.py (Repository Mapper endpoint)
│   ├── analyzer.py (Code Analyzer endpoint)
│   └── docgenie.py (DocGenie endpoint)
└── supervisor.py (Supervisor coordinator)
```

#### Option B: Deploy as Monolithic Function

Include all agents in a single deployment (simpler but may hit size limits):

```
api/
├── index.py (includes all agents)
├── routes.py (API routes)
└── agents/ (all agent code)
```

### Step 6: Handle Vercel Limitations

Vercel serverless functions have constraints:
- **Execution Time**: 10 seconds (free), 60 seconds (pro)
- **Memory**: 1024 MB (free), 3008 MB (pro)
- **Package Size**: 50 MB limit

**Solutions:**

1. **Background Processing with External Queue**:
   ```python
   # Use Upstash Redis for queue
   import redis
   
   redis_client = redis.from_url(os.getenv("REDIS_URL"))
   
   # Queue workflow
   redis_client.lpush('workflows', json.dumps({
       'workflow_id': workflow_id,
       'config': request.dict()
   }))
   ```

2. **Webhook Callbacks**:
   ```python
   # Process in background, callback when done
   async def process_workflow(workflow_id, config, callback_url):
       result = await execute_workflow(config)
       
       # Callback to update status
       await aiohttp.post(callback_url, json={
           'workflow_id': workflow_id,
           'result': result
       })
   ```

3. **External Worker Service**:
   - Deploy agents on a separate service (Railway, Fly.io, etc.)
   - Vercel API acts as gateway
   - Agents run on service with longer timeout

### Step 7: Testing Agent Integration

```python
# test_agents.py
import asyncio
import pytest
from agents.supervisor_agent.main import SupervisorAgent

@pytest.mark.asyncio
async def test_full_workflow():
    supervisor = SupervisorAgent()
    
    result = await supervisor.execute_workflow({
        'repository_url': 'https://github.com/pallets/flask',
        'branch': 'main',
        'analysis_depth': 'full',
        'include_diagrams': True,
        'format': 'markdown'
    })
    
    assert result['status'] == 'completed'
    assert 'documentation' in result
    assert len(result['files']) > 0
```

## Alternative Approach: External Agent Service

If Vercel limitations are too restrictive, consider:

### Deploy Agents on Railway/Fly.io/Render

1. **Create separate agent service**:
   ```python
   # agent_service.py
   from fastapi import FastAPI
   
   app = FastAPI()
   
   @app.post("/process")
   async def process_repository(request: RepositoryRequest):
       # Full agent processing here
       return result
   ```

2. **Update Vercel API to call agent service**:
   ```python
   # In api/routes.py
   async def generate_documentation(workflow_id, request):
       # Call external agent service
       async with aiohttp.ClientSession() as session:
           async with session.post(
               os.getenv("AGENT_SERVICE_URL") + "/process",
               json=request.dict()
           ) as response:
               result = await response.json()
       
       # Update workflow with result
       workflow_manager.update_workflow(
           workflow_id, "completed", 1.0, 
           "Documentation generated", result=result
       )
   ```

3. **Environment Variables**:
   - `AGENT_SERVICE_URL`: URL of your agent service

## Implementation Checklist

- [ ] Copy agent files to deployment directory
- [ ] Update `requirements.txt` with agent dependencies
- [ ] Integrate agents in `api/routes.py`
- [ ] Test locally with actual repositories
- [ ] Deploy to Vercel
- [ ] Verify all 4 agents are working
- [ ] Test end-to-end workflow
- [ ] Monitor performance and errors
- [ ] Optimize based on usage patterns

## Performance Considerations

1. **Repository Size**: Large repos may take 5+ minutes
2. **Code Analysis**: Tree-sitter parsing is CPU-intensive
3. **Documentation Generation**: Memory-intensive for large codebases
4. **Concurrent Workflows**: Limit to 5 simultaneous workflows

## Monitoring Agent Performance

```python
# Add performance monitoring
import time

class AgentPerformanceMonitor:
    def __init__(self):
        self.metrics = {}
        
    async def track_agent_execution(self, agent_name, task):
        start_time = time.time()
        result = await task()
        execution_time = time.time() - start_time
        
        self.metrics[agent_name] = {
            'execution_time': execution_time,
            'status': 'success' if result else 'failed'
        }
        
        return result
```

## Support

For questions about agent integration:
- **Email**: otienocavin@gmail.com
- **GitHub**: https://github.com/OumaCavin/codebase-genius/issues

## License

MIT License - Cavin Otieno
