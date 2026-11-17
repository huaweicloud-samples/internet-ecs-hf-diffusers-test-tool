# 部署指导书

> 本文档描述如何在华为云上一键创建 GPU 加速型弹性云服务器并运行图像编辑推理基准测试工具。所有命令均使用相对路径，请在仓库根目录下执行。

## 前置准备

1. 已安装 Terraform（`>= 1.5.0`）与华为云 Terraform Provider。
2. 已创建访问密钥（AK / SK），并准备经环境变量提供：
   ```bash
   export TF_VAR_access_key="<AK>"
   export TF_VAR_secret_key="<SK>"
   ```
3. 已生成 SSH 密钥对，复制公钥全文（如 `~/.ssh/id_ed25519.pub` 内容）。
4. 在控制台确认目标区域存在 GPU 加速型公共镜像（含 NVIDIA 驱动 / CUDA），记录其镜像 ID。

## 步骤 1：配置访问凭据并准备变量

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
# 编辑 terraform.tfvars，填入 ssh_public_key 与 image_id 等参数
```

> 凭据仅经环境变量提供，请勿将真实 AK / SK 写入任何文件。

## 步骤 2：初始化

```bash
terraform init
```

预期输出：`Terraform has been successfully initialized!`

## 步骤 3：预演变更

```bash
terraform plan
```

预期输出：`Plan: N to add, 0 to change, 0 to destroy.`

## 步骤 4：执行部署

```bash
terraform apply -auto-approve
```

预期输出：`Apply complete! Resources: N added, 0 changed, 0 destroyed.`

## 步骤 5：查看输出

```bash
terraform output
```

记录 `ecs_public_ip`（弹性公网 IP 地址）与 `ecs_id`，用于后续登录与验证。

## 步骤 6：登录实例并初始化运行环境

```bash
ssh root@<ecs_public_ip>
# 将本地 src/ 目录上传到实例
scp -r ../src root@<ecs_public_ip>:/opt/diffusers-bench
ssh root@<ecs_public_ip> "bash /opt/diffusers-bench/setup.sh"
```

`setup.sh` 会创建虚拟环境并安装 `requirements.txt` 中的依赖（torch / diffusers 等，耗时较长），最后运行冒烟测试确认 GPU 可用。

## 步骤 7：运行基准测试

```bash
ssh root@<ecs_public_ip>
source /opt/diffusers-bench/venv/bin/activate
cd /opt/diffusers-bench
python main.py --pipeline_vendor QwenImageEditPlusPipeline --model_type vanilla --steps 10 --cfg 4
```

推理完成后：
- 图片输出至 `output_images/<run_id>.png`
- 指标输出至 `output_metrics/<run_id>.csv`

也可在实例上执行 `make qwen_all` 或 `make flux_all` 运行预置用例组合。

## 步骤 8：释放资源

```bash
cd infra
terraform destroy -auto-approve
```

预期输出：`Destroy complete! Resources: N destroyed.`

> 释放资源后，请到控制台确认网络与计算实例已无残留，避免遗留。
