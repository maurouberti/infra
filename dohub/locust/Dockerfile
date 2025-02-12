FROM python:3.11-slim

WORKDIR /app

COPY . .
RUN chmod +x start.sh
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT [ "sh", "start.sh" ]
