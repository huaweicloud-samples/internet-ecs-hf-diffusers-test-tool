# 功能覆盖声明（T5 · A 档）

> 本文件为内部过程产物，不随华为云最佳实践对外发布。
> 用途：逐条声明原仓库 `sample-aws-ec2-hf-diffusers-test-tool` 的每个功能 / 关键文件在迁移后的承载位置，拦截「静默文件丢失」。
> 判据见 `docs/SOP/feature-coverage.md`。

## 完整声明

| 原仓库功能 / 文件 | 迁移后承载位置 | 状态 | 说明 |
|---|---|---|---|
| GPU 云服务器一键创建（IaC） | `infra/main.tf` + `infra/variables.tf` + `infra/terraform.tfvars.example` | ✅ | Terraform 声明 VPC / 子网 / 安全组 / 密钥对 / 弹性公网 IP / GPU 弹性云服务器，等价复刻原 EC2 启动逻辑 |
| 推理入口脚本（Python） | `src/main.py` | ✅ | 等价重写：Qwen / Flux 图像编辑管线、逐步骤计时、CSV 指标输出，逻辑完整保留 |
| 运行环境初始化脚本 | `src/setup.sh` | ✅ | 创建 venv、安装依赖、GPU 冒烟测试，等价复刻原启动脚本 |
| 预置用例 / 构建工具 | `src/Makefile` | ✅ | Qwen / Flux 的 vanilla 与 GGUF 多档用例目标，等价复刻原构建脚本 |
| Python 依赖清单 | `src/requirements.txt` | ✅ | torch / diffusers / huggingface-hub 等，等价复刻 |
| 部署指导书 | `docs/deployment-guide.md` | ✅ | 华为云一键部署步骤，等价于原仓库部署说明 |
| 架构说明 | `docs/architecture.md` | ✅ | mermaid 架构图 + 关键组件 + 工作流程，等价于原架构文档 |
| 产品 README | `README.md` + `README.en.md` | ✅ | 17 章结构，中英双语，等价于原 README |
| 许可证 | `LICENSE` | ✅ | 统一替换为 MIT No Attribution（Copyright Huawei Cloud），见 `others/license-modification-log.md` |
| 模型权重拉取（HuggingFace Hub） | `src/main.py` + `src/requirements.txt`（huggingface-hub） | ✅ | 运行时经公网拉取，等价于原仓库模型来源 |
| 实例启动初始化（cloud-init） | `infra/main.tf` 的 `user_data` | ✅ | 安装系统依赖 + 创建 venv + 工作目录，等价复刻原 user_data / 启动脚本 |
| 输出产物（图片 / 指标） | `src/main.py`（写出 `output_images/` 与 `output_metrics/`） | ✅ | 业务逻辑完整保留 |
| 示例数据 / 演示脚本 | 无对应（无独立 examples/ 目录） | ⏭️ | 原仓库未提供独立示例数据目录；推理输入使用 HuggingFace Hub 内置示例图，属非生产依赖，跳过 |
| tests / CI 配置 | 无对应 | ⏭️ | 原仓库为单文件推理工具，无独立测试套件；CI 非生产依赖，跳过 |

## 未识别的功能 / 孤儿文件

**结论**：无

> 经逐文件核对，原仓库核心业务能力（GPU 实例创建、推理入口、环境初始化、预置用例、依赖、文档、许可证）均在产物中有明确承载位置；无「原仓库有、产物无、且无记录说明」的静默丢失项。
