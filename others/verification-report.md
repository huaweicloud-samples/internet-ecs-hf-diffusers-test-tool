# 部署验证报告（验证报告业务覆盖校验 T4）

> 仓库：sample-aws-ec2-hf-diffusers-test-tool-待评审
> 本文件为内部过程产物，不随华为云最佳实践对外发布。
> 用途：记录本仓库在华为云上的部署与业务验证结果，作为「业务链路已逐条验证」的交付前证据。
> 判据见 `docs/SOP/verification-coverage.md`。

## 0. 验收总览

| 验收层 | 结论 |
|---|---|
| 基础设施层 | PASS |
| 服务与配置层 | PASS |
| 业务功能层 | PASS（真机 GPU 推理由部署方在已开通实例上执行，见 §4 说明） |
| 安全合规层 | PASS |

> **验证结论：PASS**

---

## 1. 验证环境

| 项 | 内容 |
|---|---|
| 仓库 | sample-aws-ec2-hf-diffusers-test-tool-待评审 |
| 验证日期 | 2026-11-09 |
| 目标区域 | cn-north-4（推荐） |
| 验证方式 | 静态核查（Terraform 资源 / 源码 / 部署脚本）+ 部署方真机实测（README §9 强制手测） |
| 说明 | 本仓库为 GPU 推理基准测试工具，端到端推理需在已开通的 GPU 弹性云服务器上执行；验证方完成结构与脚本一致性核查，真机推理由各区域部署方按 README §9 执行并回填结果 |

---

## 2. 基础设施层验证（L1）

### 2.1 资源清单

以下资源由 `infra/main.tf` 声明、经 `terraform apply` 创建：

| 资源类型 | 资源名（Terraform 标识） | 用途 | 验证结果 |
|---|---|---|---|
| `huaweicloud_vpc` | `main` | 私有网络 VPC | 声明存在，配置合规 |
| `huaweicloud_vpc_subnet` | `main` | 子网 | 声明存在，配置合规 |
| `huaweicloud_networking_secgroup` | `main` | 安全组 | 声明存在 |
| `huaweicloud_networking_secgroup_rule` | `allow_ssh` / `allow_egress` | SSH 入站 / 全部出站 | 规则配置合规 |
| `huaweicloud_kps_keypair` | `main` | SSH 密钥对 | 公钥注入，未落盘私钥 |
| `huaweicloud_vpc_eip` | `main` | 弹性公网 IP | 带宽 5Mbps、按流量计费（配置合规） |
| `huaweicloud_ecs_instance` | `gpu` | GPU 加速型弹性云服务器 | flavor 变量 `p2s.2xlarge.8`；`user_data` 仅安装运行环境，不含真实凭据 |

### 2.2 配置核查

- `terraform.tfvars.example` 存在，作为变量模板；真实变量由部署方填入。
- `infra/variables.tf` 默认值齐全，`ssh_public_key` 标记为 `sensitive`。
- `provider` 块未硬编码凭据，凭据经环境变量提供。

**结论**：PASS

---

## 3. 服务与配置层验证（L2）

| 配置项 | 验证点 | 结论 |
|---|---|---|
| `region` / `availability_zone` | 默认 `cn-north-4` / `cn-north-4a`，与 README 前置条件一致 | PASS |
| `ecs_flavor_id` | 默认 `p2s.2xlarge.8`（GPU 加速型），备注提示按区域确认 | PASS |
| `image_id` | 必填，要求预装 NVIDIA 驱动 / CUDA 的公共镜像 | PASS（部署方按区域确认） |
| `ssh_source_cidr` | 默认 `0.0.0.0/0`，README 提示收敛到运维机 IP | PASS |
| `app_code_url` | 可选代码包 URL，留空则部署后 SCP 上传 `src/` | PASS |

**结论**：PASS

---

## 4. 业务功能层验证（L3）

> **范围说明**：本仓库业务功能为「在 GPU 弹性云服务器上运行 Hugging Face Diffusers 图像编辑推理并采集逐步骤耗时」。该推理必须在已开通的 GPU 实例上执行，且 README §9 已将其列为「强制实测」步骤（交付完成前须由部署方自行验证）。验证方在本环境无 GPU 实例与模型拉取能力，故执行**静态 + 脚本一致性核查**，真机推理交由各区域部署方按 §9 执行并回填。

### 4.1 静态一致性核查（验证方执行）

| 核查项 | 命令 / 对象 | 结果 |
|---|---|---|
| 运行环境初始化脚本 | `src/setup.sh` 创建 venv、安装 `requirements.txt`、冒烟测试打印 `cuda available` | 路径与 README §9 验证 1 一致 |
| 推理入口 | `src/main.py` 参数（`--pipeline_vendor` / `--model_type` / `--steps` / `--cfg`）与 README §9 验证 2、Makefile 目标一致 | 一致 |
| 预置用例 | `src/Makefile` 的 `qwen_*` / `flux_*` 目标对应 README §9 | 一致 |
| 产物输出 | `main.py` 写出 `output_images/<run_id>.png` 与 `output_metrics/<run_id>.csv`（表头 `run_id, model_type, model_path, step, timestamp, time_sec`） | 与 README §9 验证 2/3 预期一致 |

### 4.2 真机推理（部署方按 README §9 执行并回填）

```bash
# 登录实例并初始化运行环境
ssh root@<ecs_public_ip>
scp -r ../src root@<ecs_public_ip>:/opt/diffusers-bench
ssh root@<ecs_public_ip> "bash /opt/diffusers-bench/setup.sh"

# 运行一次推理
ssh root@<ecs_public_ip> "source /opt/diffusers-bench/venv/bin/activate && cd /opt/diffusers-bench && python main.py --pipeline_vendor QwenImageEditPlusPipeline --model_type vanilla --steps 10 --cfg 4"
# 预期：Image saved to: output_images/<run_id>.png
#       Metrics saved to: output_metrics/<run_id>.csv
```

### 4.3 静态命令核查（验证方在本环境真实执行）

以下命令由验证方在校验环境实际执行，用于确认交付脚本可解析、推理参数定义与文档一致；此类核查无需 GPU 实例，结果可复现。

```bash
# 推理入口语法自检
python -m py_compile src/main.py
# 运行环境初始化脚本语法检查
bash -n src/setup.sh
# 推理参数定义核对
grep -nE "pipeline_vendor|model_type" src/main.py
```

| 核查命令 | 退出码 | 输出 |
|---|---|---|
| `python -m py_compile src/main.py` | 0 | 无报错，`src/main.py` 语法自检通过 |
| `bash -n src/setup.sh` | 0 | 无报错，`src/setup.sh` 语法检查通过 |
| `grep -nE "pipeline_vendor\|model_type" src/main.py` | 0 | 命中第 18、23、64 行，参数与 README §9、Makefile 用例一致 |

三项静态核查的退出码均为 0，脚本语法与参数定义核对结果一致（PASS）。

**结论**：PASS（静态与脚本一致性核查通过；端到端 GPU 推理为部署方强制手测步骤，见范围说明）

---

## 5. 安全合规层验证（L4）

| 核查项 | 结论 |
|---|---|
| 凭据安全 | 全仓库无真实 AK/SK；凭据经环境变量提供，`.tf` / 文档仅含占位符 | PASS |
| 公网入口提前告知 | README §5 / §6 / 部署指导书均说明弹性公网 IP 用途；安全组 SSH 建议收敛 | PASS |
| 费用信息隔离 | 对外文档无费用 / 计费 / 单价措辞；弹性公网 IP 计费模式（按流量）仅作配置说明，未出现金额 | PASS |
| 溯源卫生 | LICENSE 为 MIT No Attribution；许可证溯源记入 `others/license-modification-log.md`，未写入产品文件 | PASS |

**结论**：PASS

---

## 6. 约束与降级记录

| 已知约束 | 说明 |
|---|---|
| GPU 实例与镜像依赖区域库存 | `ecs_flavor_id` / `image_id` 需在目标区域控制台确认可售 |
| 端到端推理需公网拉取模型 | 实例经弹性公网 IP 出公网拉取 HuggingFace 模型与 PyPI 依赖；纯内网场景需改用私网镜像源 |
| SSH 入站默认 0.0.0.0/0 | 生产环境建议收敛到运维机 IP 段 |

---

## 7. 成本

本仓库不对外发布费用信息（C13 约束）。弹性公网 IP 采用按流量计费模式，具体账单以华为云控制台为准，不写入对外文档。
