"""
AWS Lambda handler for Codebase Genius
This creates a serverless API endpoint for the Codebase Genius application
"""

import json
import sys
import os
from pathlib import Path

# Add project to path
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

def lambda_handler(event, context):
    """
    AWS Lambda handler for Codebase Genius API
    
    Args:
        event: Lambda event object
        context: Lambda context object
        
    Returns:
        dict: API Gateway response
    """
    try:
        # Import your FastAPI app
        from api_frontend.api.main_api import app
        
        # Get request method and path
        http_method = event.get('httpMethod', 'GET')
        path = event.get('path', '/')
        headers = event.get('headers', {})
        
        # Create a simple response for demonstration
        # In a real implementation, you would use ASGI with Mangum
        response_body = {
            'message': 'Codebase Genius Serverless API',
            'status': 'healthy',
            'method': http_method,
            'path': path,
            'timestamp': event.get('requestContext', {}).get('requestTimeEpoch', 0)
        }
        
        # Handle different endpoints
        if path == '/health':
            response_body = {'status': 'healthy', 'service': 'codebase-genius'}
        
        elif path == '/':
            response_body.update({
                'version': '1.0.0',
                'endpoints': [
                    '/health',
                    '/docs',
                    '/analyze',
                    '/api/v1/'
                ]
            })
        
        # Basic CORS headers
        cors_headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
            'Access-Control-Max-Age': '86400'
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                **cors_headers
            },
            'body': json.dumps(response_body)
        }
        
    except ImportError as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Application import failed',
                'details': str(e)
            })
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e)
            })
        }

# Deployment script
if __name__ == "__main__":
    import boto3
    import zipfile
    
    def create_deployment_package():
        """Create deployment package for Lambda"""
        # Create zip file
        with zipfile.ZipFile('codebase-genius-lambda.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Add this file
            zipf.write(__file__, 'lambda_handler.py')
            
            # Add requirements (simplified)
            zipf.writestr('requirements.txt', '''fastapi==0.104.1
uvicorn==0.24.0
boto3==1.34.0
mangum==0.17.0
''')
            
            # Add main API
            api_dir = project_root / 'api-frontend' / 'api'
            if api_dir.exists():
                for file_path in api_dir.rglob('*.py'):
                    zipf.write(file_path, f'api/{file_path.relative_to(project_root)}')
            
            # Add agents
            agents_dir = project_root / 'agents'
            if agents_dir.exists():
                for file_path in agents_dir.rglob('*.py'):
                    zipf.write(file_path, f'agents/{file_path.relative_to(project_root)}')
        
        print("✅ Created deployment package: codebase-genius-lambda.zip")
    
    def deploy_to_aws():
        """Deploy to AWS Lambda"""
        lambda_client = boto3.client('lambda')
        
        # Create function
        response = lambda_client.create_function(
            FunctionName='codebase-genius',
            Runtime='python3.11',
            Role='arn:aws:iam::YOUR_ACCOUNT:role/lambda-execution-role',
            Handler='lambda_handler.lambda_handler',
            Code={'ZipFile': open('codebase-genius-lambda.zip', 'rb').read()},
            Description='Codebase Genius - Serverless API',
            Timeout=30,
            MemorySize=512,
            Environment={
                'Variables': {
                    'PYTHONPATH': '/var/task'
                }
            }
        )
        
        print(f"✅ Deployed to AWS Lambda: {response['FunctionArn']}")
    
    # Example usage
    create_deployment_package()
    print("Run deploy_to_aws() to deploy to AWS Lambda")
