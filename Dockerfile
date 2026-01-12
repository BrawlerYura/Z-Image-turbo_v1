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

# 2. Устанавливаем основные ноды через CLI
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
    ComfyUI-GGUF

# 3. Переустанавливаем Comfyroll начисто через Git
# Сначала удаляем папку (чтобы не было ошибки 'already exists'), потом клонируем
RUN rm -rf /comfyui/custom_nodes/ComfyUI_Comfyroll_CustomNodes && \
    cd /comfyui/custom_nodes && \
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git

# 4. УСТАНАВЛИВАЕМ КРИТИЧЕСКИЕ ЗАВИСИМОСТИ
# Без этого Comfyroll НЕ ЗАГРУЗИТСЯ в Docker, даже если папка на месте
RUN pip install --no-cache-dir opencv-python-headless Pillow

# Дублируем конфиг для подстраховки
RUN cp /comfyui/extra_model_paths.yaml /extra_model_paths.yaml
