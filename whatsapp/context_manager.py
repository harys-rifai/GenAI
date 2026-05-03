import os

def get_project_summary():
    """Returns a summary of the project structure and key files for AI context."""
    summary = "Project Structure:\n"
    # Get a simple list of files
    files = []
    for root, dirs, filenames in os.walk('.'):
        # Exclude hidden and boring stuff
        dirs[:] = [d for d in dirs if d not in ['.git', 'venv', 'node_modules', '__pycache__']]
        for f in filenames:
            if not f.endswith(('.pyc', '.log', '.sqlite3', '.pid')):
                files.append(os.path.join(root, f))
    
    summary += "\n".join(files[:50]) # Limit to 50 files for brevity
    summary += "\n\nKey File Contents:\n"
    
    # Add contents of core files
    core_files = ['genai/settings.py', 'whatsapp/views.py', 'node_gateway/index.js', 'run_service.sh']
    for cf in core_files:
        if os.path.exists(cf):
            summary += f"\n--- {cf} ---\n"
            with open(cf, 'r') as f:
                summary += f.read()[:1000] # First 1000 chars
            summary += "\n"
            
    return summary
