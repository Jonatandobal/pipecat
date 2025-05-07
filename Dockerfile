FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libsndfile1 \
    ffmpeg \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clonar el repositorio Pipecat directamente
RUN git clone https://github.com/pipecat-ai/pipecat.git /app/pipecat

# Crear y activar entorno virtual
RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

# Instalar dependencias en el entorno virtual
RUN pip install --upgrade pip && \
    pip install -e /app/pipecat && \
    pip install --no-cache-dir -r /app/pipecat/examples/phone-chatbot/requirements.txt && \
    pip install gunicorn

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Exponer puerto
EXPOSE 8000

# Comando para ejecutar el bot telefónico
CMD ["gunicorn", "--workers=1", "--log-level", "debug", "--chdir", "/app/pipecat/examples/phone-chatbot", "--capture-output", "bot_runner:app", "--bind=0.0.0.0:8000"]
