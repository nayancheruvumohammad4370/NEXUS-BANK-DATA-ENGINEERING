
import logging
from pathlib import Path

# Project log folder
base_path = Path(__file__).resolve().parents[1]
log_folder = base_path / "logs"
log_folder.mkdir(parents=True, exist_ok=True)

log_file = log_folder / "nexus_bank_pipeline.log"

# Configure logging
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    force=True
)

try:
    logging.info("NEXUS BANK customer pipeline started")

    print("Customer extraction started")
    logging.info("Customer extraction completed successfully")

    print("Customer cleaning started")
    logging.info("Customer cleaning completed successfully")

    print("NEXUS BANK pipeline completed successfully")

except Exception:
    logging.exception("Pipeline failed")
    raise

finally:
    logging.info("Pipeline execution finished")
