FROM python:3.12-slim as builder

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

COPY pyproject.toml poetry.lock* ./

# Install dependencies into the system (not venv)
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi

FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /app /app
COPY . .

EXPOSE 8501
EXPOSE 8080

CMD ["streamlit", "run", "app.py", "--server.port=$PORT", "--server.address=0.0.0.0"]
