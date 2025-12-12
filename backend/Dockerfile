FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
ENV PYTHONUNBUFFERED=1
EXPOSE 5000
CMD ["gunicorn", "-c", "gunicorn_conf.py", "app:app", "--worker-class", "eventlet", "--workers", "1"]
