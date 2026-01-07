# AGENTS.md - AI Coding Agent Guidelines

## Project Overview

This is a Python Flask REST API for managing OpenConnect VPN server (ocserv) users.
It provides endpoints for user management operations including add, remove, lock,
unlock, disconnect, and password changes.

**Repository:** https://github.com/amirmnoohi/ocserv-api

## Tech Stack

- **Language:** Python 3
- **Framework:** Flask (web framework)
- **WSGI Server:** uWSGI (production)
- **Target OS:** CentOS/RHEL or Ubuntu/Debian Linux (requires ocserv installed)

## Project Structure

```
ocserv-api/
├── ocservapi.py          # Main Flask application with all API endpoints
├── wsgi.py               # WSGI entry point for uWSGI production server
├── requirements.txt      # Python dependencies (flask, uwsgi)
├── install.sh            # CentOS/RHEL installation script
├── install-ubuntu.sh     # Ubuntu/Debian installation script
├── update.sh             # Git pull and service restart script
├── ocserv-api.service    # Systemd service configuration
└── README.md             # Basic installation instructions
```

## Build/Run Commands

### Install Dependencies

```bash
pip3 install -r requirements.txt
```

### Run Development Server

```bash
# Option 1: Flask development server with debug mode
python3 -m flask --app ocservapi run --debug --host 0.0.0.0 --port 8080

# Option 2: Direct Python execution (requires uncommenting app.run in ocservapi.py)
python3 ocservapi.py
```

### Run Production Server

```bash
uwsgi --http 0.0.0.0:8080 --master -p 4 -w wsgi:app
```

### System Service Management

```bash
# Start/Stop/Restart
sudo service ocserv-api start
sudo service ocserv-api stop
sudo service ocserv-api restart

# Enable on boot
sudo systemctl enable ocserv-api
```

## Linting and Formatting

**No linting/formatting tools are currently configured.** When adding new code,
follow PEP 8 style guidelines manually.

Recommended tools to add:

```bash
# Install
pip3 install flake8 black isort mypy

# Run linter
flake8 *.py

# Format code
black *.py
isort *.py

# Type check
mypy *.py
```

## Testing

**No test framework is currently configured.**

Recommended setup:

```bash
# Install
pip3 install pytest pytest-flask

# Run all tests
pytest

# Run single test file
pytest tests/test_users.py

# Run single test function
pytest tests/test_users.py::test_add_user

# Run with verbose output
pytest -v

# Run with coverage
pip3 install pytest-cov
pytest --cov=. --cov-report=term-missing
```

## Code Style Guidelines

### Python Version

- Use Python 3.6+ compatible syntax
- No Python 2 compatibility required

### Indentation and Formatting

- Use 4 spaces for indentation (no tabs)
- Maximum line length: 100 characters (soft limit)
- Use blank lines to separate logical sections
- Two blank lines between top-level function definitions

### Imports

- Standard library imports first
- Third-party imports second (separated by blank line)
- Local imports last (separated by blank line)
- Example from codebase:
  ```python
  import json
  import os

  from flask import Flask, make_response, request, jsonify
  ```

### Naming Conventions

- **Functions:** snake_case (e.g., `add_user`, `remove_user`, `online_users`)
- **Variables:** snake_case (e.g., `username`, `user_items`)
- **Constants:** UPPER_SNAKE_CASE (e.g., `INSTALL_DIR`)
- **API Routes:** kebab-case for multi-word routes (e.g., `/change-password`)
- **Route functions:** snake_case matching the action (e.g., `change_password`)

### String Formatting

- Use f-strings for string interpolation (Python 3.6+)
- Example: `f"Hello {username}"`
- Use double quotes for strings by convention

### API Response Pattern

All API responses should use the `output()` helper function:

```python
def output(data, code):
    response = make_response(data, code)
    response.headers["Content-Type"] = "application/json"
    return response

# Usage
return output({"code": 200, "data": result}, 200)
return output({"code": 200}, 200)
return output({"message": "Error message", "code": 400}, 400)
```

### Request Parameter Access

Use the `param()` helper for accessing JSON request body parameters:

```python
def param(inp):
    return request.json[inp]

# Usage
username = param('username')
password = param('password')
```

### Route Decorators

- GET for read operations (e.g., `/users`, `/onlines`)
- POST for write/action operations (e.g., `/add`, `/remove`, `/lock`)

### Error Handling

- Currently minimal error handling exists
- When adding new endpoints, wrap system commands in try/except
- Return appropriate HTTP status codes (200, 400, 403, 404, 500)

### System Commands

- Use `os.system()` for commands that don't need output capture
- Use `os.popen().read()` or `subprocess` for commands needing output
- Always use `sudo` for privileged operations
- Use full paths for system binaries (e.g., `/usr/bin/ocpasswd`)

## API Endpoints Reference

| Method | Endpoint           | Description                    |
|--------|-------------------|--------------------------------|
| GET    | `/`               | Access denied (403)            |
| GET    | `/users`          | List all users                 |
| GET    | `/onlines`        | List online users              |
| POST   | `/add`            | Add new user                   |
| POST   | `/remove`         | Remove user                    |
| POST   | `/lock`           | Lock user account              |
| POST   | `/unlock`         | Unlock user account            |
| POST   | `/disconnect`     | Disconnect user by username    |
| POST   | `/disconnect/id`  | Disconnect user by session ID  |
| POST   | `/change-password`| Change user password           |

## Security Notes

- API currently has no authentication - implement before production use
- Commands execute with sudo privileges via system calls
- Input validation is minimal - sanitize user inputs before shell execution
- Avoid shell injection vulnerabilities when constructing commands

## Adding New Endpoints

Follow this pattern when adding new API endpoints:

```python
@app.route('/new-endpoint', methods=['POST'])
def new_endpoint():
    # Get parameters from request
    param_value = param('param_name')
    
    # Execute system command if needed
    command = f'sudo some-command {param_value}'
    os.system(command)
    
    # Return JSON response
    return output({"code": 200}, 200)
```

## Files to Never Commit

- `.idea/` - IDE configuration
- `*.pyc` - Python bytecode
- `__pycache__/` - Python cache directory
- `.env` - Environment variables
- `*.log` - Log files
