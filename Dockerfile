#Builder stage
FROM python:3.11-slim as builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.11-slim

RUN useradd --create-home --shell /bin/bash app

WORKDIR /app

COPY --from=builder /root/.local /home/app/.local

COPY app.py .

RUN mkdir -p /app/data && chown -R app:app /app

USER app

ENV PATH=/home/app/.local/bin:$PATH

ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PORT=5000

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
	CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
