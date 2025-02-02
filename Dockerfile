# Dockerfile
FROM python:3.11-slim

RUN useradd --create-home --shell /bin/bash app_user

WORKDIR /home/app_user

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

USER app_user

COPY kraken_trade_data_extraction_cli.py ./

ENTRYPOINT [ "python", "./kraken_trade_data_extraction_cli.py"]
