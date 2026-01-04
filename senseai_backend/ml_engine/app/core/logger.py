"""
Structured logging for ML Engine
Essential for debugging, audit trail, and clinical systems
"""

import logging
import sys
from pathlib import Path

# Create logs directory if it doesn't exist
LOG_DIR = Path(__file__).parent.parent.parent / "logs"
LOG_DIR.mkdir(exist_ok=True)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(name)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.StreamHandler(sys.stdout),  # Console output
        logging.FileHandler(LOG_DIR / "ml_engine.log"),  # File output
    ]
)

# Create logger
logger = logging.getLogger("senseai-ml")

# Set log level from environment if available
import os
log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logger.setLevel(getattr(logging, log_level, logging.INFO))

