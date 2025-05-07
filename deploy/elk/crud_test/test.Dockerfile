FROM python:3.11-slim

WORKDIR /app
COPY push_test.py .
COPY els_pw.env .
RUN pip install elasticsearch==8.16.1 python-dotenv --no-cache-dir

CMD ["python", "push_test.py"]

