FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app
COPY requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY . /app

RUN addgroup --system steg && adduser --system --ingroup steg steg
RUN mkdir -p /app/uploads && chown -R steg:steg /app/uploads

USER steg

ENV FLASK_APP=app
CMD ["gunicorn", "-c", "gunicorn_conf.py", "app:create_app()"]
