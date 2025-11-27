# Use a specific hash of Alpine to ensure the OS layer never changes unexpectedly
# Python 3.9 on Alpine 3.14 (Old enough to have some OS vulnerabilities too)
FROM python:3.9-alpine3.14

WORKDIR /app

# COPY the vulnerable requirements
COPY requirements.txt .

# Install build dependencies (needed for Pillow/lxml), install python packages, 
# then delete build deps to keep the image small.
# Note: We keep the python packages installed.
RUN apk add --no-cache --virtual .build-deps gcc musl-dev libxml2-dev libxslt-dev jpeg-dev zlib-dev libffi-dev openssl-dev \
    && pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# --- GROUND TRUTH GENERATION ---
# This creates a file at /app/ground_truth_manifest.txt listing EVERYTHING.
# 1. List all OS level packages (APK)
# 2. List all Python Application packages (PIP)
RUN echo "=== OS PACKAGES (APK) ===" > ground_truth_manifest.txt \
    && apk info -vv >> ground_truth_manifest.txt \
    && echo -e "\n=== APP PACKAGES (PIP) ===" >> ground_truth_manifest.txt \
    && pip freeze >> ground_truth_manifest.txt

# Keep container running so you can inspect it if needed
CMD ["tail", "-f", "/dev/null"]
