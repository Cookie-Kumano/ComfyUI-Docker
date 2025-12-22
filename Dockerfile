FROM pytorch/pytorch:2.9.1-cuda12.8-cudnn9-runtime AS builder

ARG TORCH_CUDA_ARCH_LIST
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}

ENV DEBIAN_FRONTEND=noninteractive
ENV LIBRARY_PATH="/usr/local/cuda/lib64/stubs"

WORKDIR /tmp

RUN apt-get update && apt-get install -y git wget gnupg2 libgl1 build-essential python3-dev && \
  wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && \
  mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
  wget https://developer.download.nvidia.com/compute/cuda/12.8.1/local_installers/cuda-repo-ubuntu2204-12-8-local_12.8.1-570.124.06-1_amd64.deb && \
  dpkg -i cuda-repo-ubuntu2204-12-8-local_12.8.1-570.124.06-1_amd64.deb && \
  cp /var/cuda-repo-ubuntu2204-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
  apt-get update && apt-get -y install cuda-toolkit-12-8

RUN git clone https://github.com/thu-ml/SageAttention.git /tmp/SageAttention && \
  cd /tmp/SageAttention && \
  python setup.py install

FROM pytorch/pytorch:2.9.1-cuda12.8-cudnn9-runtime AS runner

RUN apt-get update && apt-get install -y libgl1 libglib2.0-0 git && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/conda/lib/python3.11/site-packages /opt/conda/lib/python3.11/site-packages

WORKDIR /ComfyUI

RUN git clone https://github.com/comfyanonymous/ComfyUI.git . && \
  mkdir -p custom_nodes && \
  git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager && \
  rm -rf .git/ custom_nodes/ComfyUI-Manager/.git/

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

EXPOSE 8188
CMD ["python", "main.py", "--listen"]