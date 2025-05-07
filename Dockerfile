```dockerfile
# Base image más ligera
FROM python:3.11-slim

# Directorio de trabajo
WORKDIR /app

# Instalar solo las dependencias esenciales del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    libsndfile1 \
    ffmpeg \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copiar solo los archivos necesarios
COPY requirements.txt .
COPY pyproject.toml .
COPY setup.py .
COPY src/ ./src/
COPY examples/phone-chatbot/ ./examples/phone-chatbot/

# Instalar dependencias con pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -e .
RUN pip install --no-cache-dir -r examples/phone-chatbot/requirements.txt
RUN pip install --no-cache-dir gunicorn

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Exponer puerto
EXPOSE 8000

# Comando para ejecutar el bot telefónico
CMD ["gunicorn", "--workers=1", "--log-level", "debug", "--chdir", "examples/phone-chatbot", "--capture-output", "bot_runner:app", "--bind=0.0.0.0:8000"]
