"""
Structured logging for ML Engine
Essential for debugging, audit trail, and clinical systems
"""

import logging
import sys
import io
from pathlib import Path

# Create logs directory if it doesn't exist
LOG_DIR = Path(__file__).parent.parent.parent / "logs"
LOG_DIR.mkdir(exist_ok=True)

# Fix Unicode encoding for Windows console
if sys.platform == "win32":
    # Wrap stdout to handle UTF-8 encoding
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    if hasattr(sys.stderr, 'reconfigure'):
        sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# Create UTF-8 compatible stream handler
class UTF8StreamHandler(logging.StreamHandler):
    """Stream handler that handles UTF-8 encoding properly"""
    def __init__(self, stream=None):
        if stream is None:
            stream = sys.stdout
        super().__init__(stream)
    
    def emit(self, record):
        try:
            msg = self.format(record)
            # Replace problematic Unicode characters for Windows console
            if sys.platform == "win32":
                msg = msg.replace('✅', '[OK]').replace('❌', '[ERROR]').replace('⚠️', '[WARNING]')
            stream = self.stream
            stream.write(msg + self.terminator)
            self.flush()
        except Exception:
            self.handleError(record)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(name)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        UTF8StreamHandler(sys.stdout),  # Console output with UTF-8 handling
        logging.FileHandler(LOG_DIR / "ml_engine.log", encoding='utf-8'),  # File output
    ]
)

# Create logger
logger = logging.getLogger("senseai-ml")

# Set log level from environment if available
import os
log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logger.setLevel(getattr(logging, log_level, logging.INFO))


