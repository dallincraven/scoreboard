FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    curl \
    git \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install poetry

COPY pyproject.toml poetry.lock* README.md ./

# Install dependencies into the system (not venv)
RUN poetry config virtualenvs.create false \
 && poetry lock \
 && poetry install --no-root --no-interaction --no-ansi

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /app /app
# bring installed packages and console scripts from builder (pip/poetry global installs)
COPY --from=builder /usr/local /usr/local
COPY . .

EXPOSE 8501
EXPOSE 8080

CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]
