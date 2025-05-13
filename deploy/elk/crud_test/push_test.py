# TODO: Hanlde secrets from yaml side
from elasticsearch import Elasticsearch
import os

els_pw = os.environ["ELS_PW"]
els_id = "elastic"


es = Elasticsearch(
    ["https://elastintest-es-http:9200"],
    basic_auth=(els_id, els_pw),
    verify_certs=False  # use tls later
)

doc = {"message": "Hello from the other side 🎶"}
resp = es.index(index="test-index", document=doc)
print("Push response: ", resp)
doc_id = resp["_id"]
retrieved = es.get(index="test-index", id=doc_id)
print("Get response:", retrieved["_source"])
