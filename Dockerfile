# Используем базовый образ runpod для серверлесс
FROM runpod/worker-comfyui:5.5.1-base

RUN cd /workspace/runpod-slim/ComfyUI && git pull && pip install -r requirements.txt

# 1. Устанавливаем кастомные ноды (они занимают мало места, оставляем в образе)
RUN comfy node install --exit-on-fail comfyui-impact-subpack --mode remote
RUN comfy node install --exit-on-fail comfyui-impact-pack
RUN comfy node install --exit-on-fail rgthree-comfy
RUN comfy node install --exit-on-fail comfy-image-saver
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN comfy node install --exit-on-fail RES4LYF
RUN comfy node install --exit-on-fail crt-nodes
RUN comfy node install --exit-on-fail ControlAltAI-Nodes
RUN comfy node install --exit-on-fail was-node-suite-comfyui
RUN comfy node install --exit-on-fail ComfyUI_Comfyroll_CustomNodes

# 2. Создаем конфиг, который заставит ComfyUI искать модели на сетевом томе
RUN echo "runpod_volume:" > /extra_model_paths.yaml && \
    echo "    base_path: /runpod-volume" >> /extra_model_paths.yaml && \
    echo "    checkpoints: checkpoints" >> /extra_model_paths.yaml && \
    echo "    unet_gguf: unet_gguf" >> /extra_model_paths.yaml && \
    echo "    unet: unet_gguf" >> /extra_model_paths.yaml && \
    echo "    text_encoders: text_encoders" >> /extra_model_paths.yaml && \
    echo "    vae: vae" >> /extra_model_paths.yaml && \
    echo "    loras: loras" >> /extra_model_paths.yaml && \
    echo "    ultralytics: ultralytics" >> /extra_model_paths.yaml && \
    echo "    sams: sams" >> /extra_model_paths.yaml && \
    echo "    diffusion_models: diffusion_models" >> /extra_model_paths.yaml && \
    echo "    upscale_models: upscale_models" >> /extra_model_paths.yaml

# Копируем конфиг во все возможные места установки ComfyUI для подстраховки
RUN cp /extra_model_paths.yaml /comfyui/extra_model_paths.yaml || true
RUN mkdir -p /workspace/runpod-slim/ComfyUI && cp /extra_model_paths.yaml /workspace/runpod-slim/ComfyUI/extra_model_paths.yaml || true
