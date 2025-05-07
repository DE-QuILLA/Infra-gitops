FROM python:3.11-slim

WORKDIR /app
COPY push_test.py .
RUN pip install elasticsearch==8.13.0 --no-cache-dir

CMD ["python", "push_test.py"]

