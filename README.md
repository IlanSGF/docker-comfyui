# Docker for Stable Diffusion ComfyUI

The Dockerfile pull the latest HEAD from comfyanonymous SD Webui (https://github.com/comfyanonymous/ComfyUI).

# docker-shared filestructure
Create a folder:
```
mkdir $HOME/docker-shared
```
to hold models instead of having them copied on every container run:
```
docker-shared/
├── checkpoints/
├── embeddings/
├── loras/
├── upscaler/
└── vae/
```

To build the image:
```
cd docker-comfyui
docker build -t confyui .
docker run --gpus all -p 8188:8188 -v /home/titanium/docker-shared:/app/repo/docker-shared confyui
```
