FROM python:3.11-slim

ENV PIP_DEFAULT_TIMEOUT=1000 \
    PIP_RETRIES=10 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# 複製並安裝 Python 依賴
COPY requirements.txt .
RUN pip install --no-cache-dir \
    --index-url https://download.pytorch.org/whl/cpu \
    "torch==2.3.1+cpu"
RUN pip install --no-cache-dir -r requirements.txt

# 複製腳本
COPY upgrade_vector_db.py .

# 預設指令
CMD ["python", "upgrade_vector_db.py"]
