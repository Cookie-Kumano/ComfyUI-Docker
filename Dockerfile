FROM nvcr.io/nvidia/pytorch:25.11-py3

WORKDIR /ComfyUI

RUN apt-get update && \
    apt-get install -y libgl1 && \
    git clone https://github.com/comfyanonymous/ComfyUI.git . && \
    mkdir -p custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager && \
    rm -rf /root/.cache/pip && \
    rm -rf .git/ && \
    rm -rf custom_nodes/ComfyUI-Manager/.git/ && \
    rm -rf /var/lib/apt/lists/*

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

CMD ["python3", "main.py", "--listen"]