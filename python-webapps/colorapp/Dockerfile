
# Multi-stage build for smaller final image
FROM python:3.12-slim AS base

# Set a working directory
WORKDIR /app

# Metadata labels
LABEL version="1.0.0" \
      description="Color App - Flask-based web app that changes background color" \
      maintainer="RoboKing Master<robokingmaster@gmail.com>"

# Ensure no bytecode + unbuffered logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install minimal system dependencies (for pip and runtime)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency list first for better layer caching
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY app.py /app/app.py

# Create a non-root user for security
RUN useradd -m -u 10001 appuser
USER appuser

# Expose the app port
EXPOSE 8080

# Healthcheck (Gunicorn responds on 8080)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:8080/ || exit 1

# Default ENV (can be overridden at runtime)
ENV APP_COLOR=steelblue

# Use Gunicorn as a production server
# -w: workers; -b: bind address
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8080", "app:app"]

