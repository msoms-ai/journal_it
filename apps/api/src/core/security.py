import os
import base64
from datetime import datetime, timedelta
from typing import Optional, Union, Any
import bcrypt
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from jose import jwt
from src.core.config import settings

class SecretVaultService:
    """
    AES-256-GCM authenticated encryption service for securely storing
    BYOK Gemini API keys and journalistic credentials.
    """
    def __init__(self, master_key_b64: Optional[str] = None):
        key_str = master_key_b64 or settings.VAULT_MASTER_KEY_B64
        try:
            self.master_key = base64.b64decode(key_str)
            if len(self.master_key) != 32:
                self.master_key = (self.master_key + b"0" * 32)[:32]
        except Exception:
            self.master_key = b"0" * 32
        self.aesgcm = AESGCM(self.master_key)

    def encrypt_secret(self, plaintext_secret: str) -> str:
        nonce = os.urandom(12)  # 96-bit nonce for GCM
        ciphertext = self.aesgcm.encrypt(nonce, plaintext_secret.encode("utf-8"), None)
        return base64.b64encode(nonce + ciphertext).decode("utf-8")

    def decrypt_secret(self, encrypted_payload: str) -> str:
        data = base64.b64decode(encrypted_payload.encode("utf-8"))
        nonce = data[:12]
        ciphertext = data[12:]
        plaintext = self.aesgcm.decrypt(nonce, ciphertext, None)
        return plaintext.decode("utf-8")

vault_service = SecretVaultService()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(plain_password.encode("utf-8")[:72], hashed_password.encode("utf-8"))
    except Exception:
        return False

def get_password_hash(password: str) -> str:
    pwd_bytes = password.encode("utf-8")[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode("utf-8")

def create_access_token(subject: Union[str, Any], tenant_id: str, role: str, expires_delta: Optional[timedelta] = None) -> str:
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "tenant_id": str(tenant_id),
        "role": role,
        "iat": datetime.utcnow()
    }
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except Exception:
        return None
