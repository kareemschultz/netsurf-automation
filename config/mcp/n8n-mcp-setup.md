# n8n MCP Server Setup

The n8n MCP server allows Claude Code to manage workflows programmatically.

## Installation

```bash
npm install -g @n8n/n8n-mcp-server
```

## Configuration

Add to Claude Code's MCP settings:

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": ["-y", "@n8n/n8n-mcp-server"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

## Getting an n8n API Key

1. Login to n8n at http://localhost:5678
2. Go to Settings (bottom left)
3. Click "API"
4. Click "Create an API Key"
5. Copy the key and add to MCP config

## Available Tools

Once configured, these tools are available:

### Workflow Management
- `n8n_list_workflows` - List all workflows
- `n8n_get_workflow` - Get workflow by ID
- `n8n_create_workflow` - Create new workflow
- `n8n_update_workflow` - Update existing workflow
- `n8n_delete_workflow` - Delete workflow
- `n8n_activate_workflow` - Activate workflow
- `n8n_deactivate_workflow` - Deactivate workflow

### Execution Management
- `n8n_list_executions` - List workflow executions
- `n8n_get_execution` - Get execution details
- `n8n_run_workflow` - Manually trigger workflow

### Credential Management
- `n8n_list_credentials` - List stored credentials
- `n8n_create_credential` - Create new credential
- `n8n_delete_credential` - Delete credential

## Example Usage

### Import a Workflow
```javascript
// Using n8n MCP
const workflow = await n8n_create_workflow({
  name: "My Workflow",
  nodes: [...],
  connections: {...},
  active: false
});
```

### Activate Workflow
```javascript
await n8n_activate_workflow({ id: workflow.id });
```

### Run Workflow Manually
```javascript
const execution = await n8n_run_workflow({
  workflowId: "123",
  data: { message: "test" }
});
```

## Troubleshooting

### "Connection refused"
- Ensure n8n is running: `docker compose ps`
- Check n8n is accessible: `curl http://localhost:5678/healthz`

### "Unauthorized"
- API key may be invalid
- Regenerate key in n8n settings

### "Workflow not found"
- Use correct workflow ID (number, not name)
- List workflows first to get IDs

## Security Notes

- API keys have full access to n8n
- Don't commit API keys to version control
- Rotate keys periodically
- Use environment variables for keys
