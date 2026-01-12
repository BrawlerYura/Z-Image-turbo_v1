# Используем базовый образ runpod
FROM runpod/worker-comfyui:5.5.1-base

USER root

# 1. Устанавливаем системные зависимости и обновляем ComfyUI в ОДНОМ слое
RUN apt-get update && apt-get install -y git && \
    cd /comfyui && \
    git fetch --all && \
    git reset --hard origin/master && \
    pip install --no-cache-dir --upgrade -r requirements.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Устанавливаем ВСЕ кастомные ноды ОДНОЙ командой
# Это значительно уменьшает размер образа и нагрузку на сборщик
RUN comfy node install --exit-on-fail \
    comfyui-impact-subpack \
    comfyui-impact-pack \
    rgthree-comfy \
    comfy-image-saver \
    comfyui-kjnodes \
    RES4LYF \
    crt-nodes \
    ControlAltAI-Nodes \
    was-node-suite-comfyui \
    ComfyUI_Comfyroll_CustomNodes \
    ComfyUI-GGUF

# 3. Создаем конфиг путей
RUN echo "runpod_volume:" > /comfyui/extra_model_paths.yaml && \
    echo "    base_path: /runpod-volume" >> /comfyui/extra_model_paths.yaml && \
    echo "    checkpoints: checkpoints" >> /comfyui/extra_model_paths.yaml && \
    echo "    unet: unet_gguf" >> /comfyui/extra_model_paths.yaml && \
    echo "    unet_gguf: unet_gguf" >> /comfyui/extra_model_paths.yaml && \
    echo "    clip: text_encoders" >> /comfyui/extra_model_paths.yaml && \
    echo "    vae: vae" >> /comfyui/extra_model_paths.yaml && \
    echo "    loras: loras" >> /comfyui/extra_model_paths.yaml && \
    echo "    ultralytics: ultralytics" >> /comfyui/extra_model_paths.yaml && \
    echo "    sams: sams" >> /comfyui/extra_model_paths.yaml && \
    echo "    diffusion_models: unet_gguf" >> /comfyui/extra_model_paths.yaml && \
    echo "    upscale_models: upscale_models" >> /comfyui/extra_model_paths.yaml

# 3. Устанавливаем Comfyroll вручную через Git, чтобы точно попасть в имя
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# 4. ФИКС ЗАВИСИМОСТЕЙ (Критически важно для работы CR Upscale Image)
# Устанавливаем headless-версию OpenCV и Pillow
RUN pip install --no-cache-dir opencv-python-headless Pillow

# Дублируем конфиг для подстраховки
RUN cp /comfyui/extra_model_paths.yaml /extra_model_paths.yaml
