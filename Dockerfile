# Use NVIDIA CUDA image with full development tools (Ubuntu 22.04)
FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Set environment variables for CUDA
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4"

# Install dependencies, including TCMalloc (Google Performance Tools)
RUN apt update && apt install -y \
    wget curl git sudo build-essential \
    python3 python3-pip python3-venv \
    libgoogle-perftools-dev \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y libgl1 libglib2.0-0
RUN apt update && apt install -y pkg-config cmake \
    gcc make

# Create a non-root user
RUN useradd -m webui && \
    mkdir -p /app/repo && chown -R webui:webui /app

# Set working directory
WORKDIR /app/repo

# Clone the Stable Diffusion WebUI repo
RUN git clone https://github.com/comfyanonymous/ComfyUI .

# Change ownership to `webui` before switching users
RUN chown -R webui:webui /app/repo

# Switch to non-root user
USER webui

# Install requirements
RUN pip install sentencepiece
RUN pip install -r requirements.txt

# Install Python dependencies inside a virtual environment
RUN python3 -m venv venv && \
    venv/bin/pip install --upgrade pip && \
    venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# TODO add ComfyUI manager

# Expose port 8188 for Web UI
EXPOSE 8188

# Hiperlinked folders to shared volume
RUN ln -s /app/repo/docker-shared/models/loras /app/repo/models/loras
RUN rm -rf /app/repo/models/checkpoints
RUN ln -s /app/repo/docker-shared/models/checkpoints /app/repo/models/
RUN rm -rf /app/repo/models/vae
RUN ln -s /app/repo/docker-shared/models/vae /app/repo/models/
RUN ln -s /app/repo/docker-shared/models/upscaler /app/repo/models/upscale_models
RUN rm -rf /app/repo/output
RUN ln -s /app/repo/docker-shared/outputs /app/repo/output

# Run the Web UI
CMD ["python3", "main.py", "--listen"]
