# Input: Python JWT Authentication Module

**Artifact type:** Python source code  
**File:** `auth/jwt_handler.py` (~60 lines)  
**Context:** Submitted by a developer on the Payments team for a pre-release review before rolling out to production. The module handles JWT issuance and verification for an internal REST API gateway.

---

```python
# auth/jwt_handler.py
# JWT authentication handler for the API gateway
# Last modified: 2024-01-15 by devteam

import jwt
import datetime
import logging
from flask import request, jsonify

SECRET_KEY = "dev-secret-key-dont-use-in-prod"
ALGORITHM = "HS256"

logger = logging.getLogger(__name__)


def create_token(user_id: str, roles: list) -> str:
    """Create a JWT token for the given user."""
    payload = {
        "sub": user_id,
        "roles": roles,
        "iat": datetime.datetime.utcnow(),
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token


def verify_token(token: str) -> dict:
    """Verify and decode a JWT token. Returns the payload if valid."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except Exception as e:
        logger.error(f"Token verification failed: {e}")
        return {}


def require_auth(f):
    """Decorator to protect routes requiring authentication."""
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Missing or invalid token"}), 401

        token = auth_header[7:]
        payload = verify_token(token)
        if not payload:
            return jsonify({"error": "Token validation failed"}), 401

        request.user = payload
        return f(*args, **kwargs)
    return wrapper


def require_role(role: str):
    """Decorator to require a specific role."""
    def decorator(f):
        def wrapper(*args, **kwargs):
            user = getattr(request, "user", {})
            if role not in user.get("roles", []):
                return jsonify({"error": "Insufficient permissions"}), 403
            return f(*args, **kwargs)
        return wrapper
    return decorator


# Endpoint: POST /auth/verify
# Exposed publicly — clients can verify tokens directly
from flask import Blueprint
auth_bp = Blueprint("auth", __name__)

@auth_bp.route("/auth/verify", methods=["POST"])
def verify_endpoint():
    """Public endpoint: verify a token and return decoded claims."""
    data = request.get_json()
    token = data.get("token", "")
    result = verify_token(token)
    if result:
        return jsonify({"valid": True, "claims": result})
    return jsonify({"valid": False}), 401
```
