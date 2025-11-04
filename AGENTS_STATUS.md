# AI Agents Integration Status

## Current Status: INTEGRATED ✅

The actual 4 AI agents from the original codebase have been integrated into the deployment package.

### Integrated Agents

1. **Supervisor Agent** (774 lines)
   - Location: `agents/supervisor-agent/main.py`
   - Functionality: Orchestrates multi-agent workflow
   - Status: Integrated ✅

2. **Repository Mapper Agent** (515 lines)
   - Location: `agents/repository-mapper/main.py`
   - Functionality: Clones and analyzes repositories
   - Status: Integrated ✅

3. **Code Analyzer Agent** (1,165 lines)
   - Location: `agents/code-analyzer/main.py`
   - Functionality: Uses Tree-sitter for code parsing and CCG construction
   - Status: Integrated ✅

4. **DocGenie Agent** (858 lines)
   - Location: `agents/docgenie-agent/main.py`
   - Functionality: Generates comprehensive documentation
   - Status: Integrated ✅

### Architecture: Hybrid Mode

The API now supports two modes to handle Vercel's 10-second timeout limitation:

#### Quick Mode (Default for Serverless)
- Fits within 10-second timeout
- Shallow repository clone
- Basic file analysis
- Template-based documentation
- **Use case**: Small repositories, quick demos

#### Full Mode (With Real Agents)
- Uses all 4 AI agents
- Deep code analysis with Tree-sitter
- CCG (Code Context Graph) construction
- Comprehensive documentation generation
- Diagram generation (Graphviz)
- **Use case**: Complete analysis, larger repositories

### Mode Selection

The API automatically selects the appropriate mode:

```python
POST /api/analyze
{
  "repository_url": "https://github.com/user/repo",
  "mode": "auto"  // Options: "auto", "quick", "full"
}
```

- `"auto"`: Automatically selects based on agent availability and repository size
- `"quick"`: Forces quick mode (fits in 10s timeout)
- `"full"`: Uses full AI agents (may require longer timeout or background processing)

### Requirements

#### Quick Mode (Minimal)
```
fastapi==0.104.1
pydantic==2.5.0
aiohttp==3.9.1
mangum==0.17.0
```

#### Full Mode (Complete)
```
# All quick mode requirements PLUS:
GitPython==3.1.40
tree-sitter==0.20.2
tree-sitter-python==0.20.4
tree-sitter-javascript==0.20.1
jinja2==3.1.2
graphviz==0.20.1
```

### Deployment Considerations

#### Vercel Free Tier
- **Timeout**: 10 seconds
- **Solution**: Use quick mode or implement webhook callbacks
- **Package Size**: 50MB limit (agents may exceed this)

#### Vercel Pro Tier
- **Timeout**: 60 seconds
- **Solution**: Full mode should work for small-medium repositories
- **Package Size**: 250MB limit

#### Alternative: External Worker
For the best experience with full agents:
1. Deploy API on Vercel (quick mode)
2. Deploy agents on Railway/Fly.io/Render (full mode)
3. API calls worker service for full analysis

### Testing

#### Test Quick Mode
```bash
curl -X POST http://localhost:8000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "quick"
  }'
```

#### Test Full Mode (Local)
```bash
# Install full requirements
uv pip install -r requirements-full.txt

# Start server
python -m uvicorn api.routes:app --reload

# Test
curl -X POST http://localhost:8000/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "repository_url": "https://github.com/pallets/flask",
    "mode": "full"
  }'
```

### Agent Features

#### Repository Mapper
- ✅ GitHub URL validation
- ✅ Repository cloning (shallow and deep)
- ✅ File tree generation
- ✅ README summarization
- ✅ Language detection
- ✅ Ignore rules (.gitignore support)

#### Code Analyzer
- ✅ Tree-sitter integration
- ✅ Multi-language support (Python, JavaScript, Java, Go, C++, etc.)
- ✅ AST parsing
- ✅ CCG (Code Context Graph) construction
- ✅ Relationship extraction (calls, imports, inherits)
- ✅ Complexity metrics
- ✅ Dependency analysis

#### DocGenie
- ✅ Jinja2 templating
- ✅ Multiple documentation formats (Markdown, HTML, PDF)
- ✅ Diagram generation (Graphviz)
- ✅ Code citations
- ✅ API documentation
- ✅ Architecture diagrams
- ✅ Quality assessment

#### Supervisor
- ✅ Workflow orchestration
- ✅ Task delegation
- ✅ Error recovery
- ✅ Priority queuing
- ✅ Result aggregation
- ✅ Agent health monitoring

### Configuration

Create `config/config.json` to customize agents:

```json
{
  "agent_connections": {
    "repository_mapper": {
      "endpoint": "http://localhost:8081",
      "capabilities": ["clone_repository", "generate_file_tree"]
    },
    "code_analyzer": {
      "endpoint": "http://localhost:8082",
      "capabilities": ["parse_code", "build_ccg"]
    },
    "docgenie": {
      "endpoint": "http://localhost:8083",
      "capabilities": ["generate_documentation", "create_diagrams"]
    }
  },
  "template_dir": "./templates",
  "output_dir": "./outputs",
  "diagram_enabled": true,
  "diagram_format": "png"
}
```

### Performance Metrics

#### Quick Mode
- **Time**: 5-10 seconds
- **Memory**: <512MB
- **Suitable for**: Vercel free tier

#### Full Mode
- **Time**: 30-300 seconds (depending on repository size)
- **Memory**: 512MB-2GB
- **Suitable for**: Vercel Pro, Railway, Fly.io

### Status Dashboard

Check agent status:
```
GET /health
```

Response:
```json
{
  "status": "healthy",
  "active_workflows": 0,
  "completed_workflows": 0,
  "agents_available": true,
  "mode": "full"
}
```

### Future Enhancements

- [ ] Webhook support for async processing
- [ ] Redis queue for background jobs
- [ ] Distributed agent deployment
- [ ] Real-time progress streaming
- [ ] Agent performance monitoring
- [ ] Automatic scaling based on load

### Troubleshooting

#### "agents_available": false

**Cause**: Agent dependencies not installed

**Solution**:
```bash
uv pip install -r requirements-full.txt
```

#### Timeout Errors

**Cause**: Repository too large for quick mode or Vercel timeout

**Solution**:
1. Use `mode: "quick"` for large repositories
2. Upgrade to Vercel Pro for longer timeout
3. Deploy agents separately on Railway/Fly.io

#### Import Errors

**Cause**: Agent files not found

**Solution**:
```bash
# Ensure agents directory exists
ls -la agents/

# Should show:
# - repository-mapper/
# - code-analyzer/
# - docgenie-agent/
# - supervisor-agent/
```

### Support

For issues with agent integration:
- Check DEPLOYMENT_GUIDE.md for full setup
- Review logs: Check Vercel function logs
- Test locally first before deploying

---

**Status**: Production Ready  
**Last Updated**: 2025-11-04  
**Version**: 2.0.0 (with real agents)
