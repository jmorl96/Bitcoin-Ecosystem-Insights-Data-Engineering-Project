# Dockerfile
FROM python:3.11-slim

RUN useradd --create-home --shell /bin/bash app_user

WORKDIR /home/app_user

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

ADD kraken_analytics/ ./

RUN chown -R app_user /home/app_user

USER app_user

RUN dbt deps

ENTRYPOINT [ "dbt"]
