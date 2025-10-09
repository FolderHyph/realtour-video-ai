FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ----------------------------------------------------
# 🧩 1️⃣ Configuración base
# ----------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
WORKDIR /

# ----------------------------------------------------
# 🧩 2️⃣ Instalación de dependencias del sistema
# ----------------------------------------------------
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt install --yes --no-install-recommends \
    git git-lfs wget curl bash libgl1 software-properties-common \
    openssh-server ffmpeg && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt install "python3.10-dev" -y --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# ----------------------------------------------------
# 🧩 3️⃣ Instalación de Python y pip
# ----------------------------------------------------
RUN ln -s /usr/bin/python3.10 /usr/bin/python && \
    rm /usr/bin/python3 && \
    ln -s /usr/bin/python3.10 /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py

RUN pip install --upgrade --no-cache-dir pip

# ----------------------------------------------------
# 🧩 4️⃣ Clonar e instalar el modelo base SVD
# ----------------------------------------------------
RUN mkdir -p /usr/share/svd
WORKDIR /usr/share/svd
RUN git clone https://github.com/Stability-AI/generative-models.git

WORKDIR /usr/share/svd/generative-models

# 💡 Aquí estaba el error principal (blinker)
RUN pip uninstall -y blinker || true && \
    pip install --ignore-installed --no-cache-dir -r requirements/pt2.txt && \
    pip install --ignore-installed --no-cache-dir . && \
    pip install --ignore-installed --no-cache-dir streamlit

ENV PYTHONPATH="/usr/share/svd/generative-models"

RUN git lfs install

# ----------------------------------------------------
# 🧩 5️⃣ Añadir tus dependencias RealTour
# ----------------------------------------------------
WORKDIR /workspace

# Copiamos tu código y handler personalizado
COPY . /workspace

# Instalamos librerías necesarias para Firebase + RunPod
RUN pip install --no-cache-dir google-cloud-storage firebase-admin runpod

# (Opcional) Si subes firebase-key.json al repo privado, cópialo
# COPY firebase-key.json /workspace/firebase-key.json

# ----------------------------------------------------
# 🧩 6️⃣ Variables de entorno y entrypoint
# ----------------------------------------------------
ENV GOOGLE_APPLICATION_CREDENTIALS=/workspace/firebase-key.json
ENV PYTHONUNBUFFERED=1
ENV PORT=3000

# 🚀 Nuevo entrypoint serverless
CMD ["python3", "handler.py"]
