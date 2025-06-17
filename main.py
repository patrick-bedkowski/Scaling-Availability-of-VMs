import asyncio
import logging
import time

import psutil
from cpu_load_generator import load_all_cores
from fastapi import FastAPI

app = FastAPI()
logging.basicConfig(filename='requests.log', level=logging.INFO, format='%(asctime)s %(message)s')


@app.get("/")
async def root():
    start = time.time()
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, load_all_cores, 1, 0.1)
    end = time.time()
    logging.info(f"Request processed in {end - start:.2f} seconds")
    return {"message": "Request processed", "processing_time": f"{end - start:.2f} seconds"}


@app.get("/metrics")
async def metrics():
    cpu_percent = psutil.cpu_percent(interval=1)
    return {
        "cpu_percent": cpu_percent
    }
