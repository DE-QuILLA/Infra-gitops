from elasticsearch import Elasticsearch
from dotenv import load_dotenv
import os

load_dotenv("els_pw.env")

els_pw = os.getenv("ELS_PW")
els_id = "elastic"

es = Elasticsearch(
    ["https://elastintest-es-http.elastic-system.svc:9200"],
    basic_auth=(els_id, els_pw),
    verify_certs=False  # use tls later
)

doc = {"message": "Hello from the other side 🎶"}
resp = es.index(index="test-index", document=doc)
print(resp)
