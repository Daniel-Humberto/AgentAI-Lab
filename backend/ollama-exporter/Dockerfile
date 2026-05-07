FROM python:3.11-slim

WORKDIR /app

RUN pip install fastapi uvicorn prometheus_client httpx

COPY ollama_exporter.py .

EXPOSE 8000

CMD ["python", "ollama_exporter.py"]
