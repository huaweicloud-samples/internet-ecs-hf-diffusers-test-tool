#!/usr/bin/env bash
# 弹性云服务器上的运行环境初始化脚本
# 用法：部署完成后，登录弹性云服务器，将本目录上传至 /opt/diffusers-bench 后执行：
#   bash setup.sh
set -e

WORKDIR="/opt/diffusers-bench"
VENV="${WORKDIR}/venv"

echo "[1/3] 创建并激活虚拟环境"
python3 -m venv "${VENV}"
# shellcheck disable=SC1091
source "${VENV}/bin/activate"

echo "[2/3] 安装 Python 依赖（torch / diffusers 等，耗时较长）"
pip install --upgrade pip
pip install -r "${WORKDIR}/requirements.txt"

echo "[3/3] 运行冒烟测试：确认 PyTorch 可识别 GPU"
python - <<'PY'
import torch
print("torch version:", torch.__version__)
print("cuda available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("device count:", torch.cuda.device_count())
    print("device name :", torch.cuda.get_device_name(0))
PY

echo ""
echo "环境就绪。运行示例："
echo "  source ${VENV}/bin/activate"
echo "  cd ${WORKDIR}"
echo "  python main.py --pipeline_vendor QwenImageEditPlusPipeline --model_type vanilla --steps 10 --cfg 4"
