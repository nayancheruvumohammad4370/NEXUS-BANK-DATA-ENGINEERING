
import logging
from pathlib import Path

base_path = Path(__file__).resolve().parents[1]
log_folder = base_path / "logs"
log_folder.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    filename=log_folder / "nexus_bank_pipeline.log",
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    force=True
)

try:
    logging.info("Exception handling test started")

    result = 100 / 0

    print("Result:", result)

except ZeroDivisionError:
    print("Error captured: Cannot divide by zero")
    logging.exception("ZeroDivisionError occurred")

finally:
    print("Pipeline execution finished")
    logging.info("Exception handling test finished")
