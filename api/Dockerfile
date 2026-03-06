FROM python:3.11.12-slim

LABEL org.opencontainers.image.title="AGAMA API" \
      org.opencontainers.image.description="A Generic App to Manage Anything" \
      org.opencontainers.image.base.name="python:3.11.12-slim"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/      ./app/

RUN useradd -m appuser && chown -R appuser /app
USER appuser

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
