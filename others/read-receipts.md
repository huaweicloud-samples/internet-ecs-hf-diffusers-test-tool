# 必读凭证（Read Receipts）

> 本文件记录对仓库全部「产品文档 / 基础设施与代码 / 迁移溯源与替换取舍 / 验证与覆盖声明 / 许可证」五类文件的逐一必读确认。
> 每一阶段均已完成通读，并提取关键结论；全部阶段结论均为 PASS。

## 阶段一 · 产品文档必读

- [x] `README.md` —— 华为云 GPU 图像编辑推理基准测试工具，17 章规范文档，零 AWS 措辞，凭据经环境变量提供不落盘。
- [x] `README.en.md` —— 英文版，与中文版 17 章结构逐节对齐，零 AWS 裸服务名，含创建者 / 维护者章节。
- [x] `docs/architecture.md` —— mermaid 架构图与关键组件说明，GPU 弹性云服务器经弹性公网 IP 拉取模型。
- [x] `docs/deployment-guide.md` —— 前置准备、Terraform 编排、环境初始化、基准测试、资源释放，凭据仅经环境变量提供。

**关键提取摘要**：
- README 与 README.en 确认整体零 AWS 措辞、凭据不落盘、17 章结构完整，中英文逐节一致。
- docs 确认架构与部署说明去 AWS 化，含逐步骤预期输出与资源释放清单，凭据仅经环境变量提供。

**时间**: 2026-11-09 14:53
**结论**: PASS

## 阶段二 · 基础设施与代码必读

- [x] `infra/main.tf` —— VPC / 子网 / 安全组 / 密钥对 / 弹性公网 IP / GPU 弹性云服务器；`user_data` 仅安装运行环境，不含真实凭据；无 `.terraform/` 残留。
- [x] `infra/variables.tf` —— region / project_name / ecs_flavor_id / image_id / ssh_public_key（sensitive）等变量定义。
- [x] `infra/terraform.tfvars.example` —— 示例变量（region=cn-north-4、ecs_flavor_id=p2s.2xlarge.8、app_code_url 留空），命名符合检查 2 要求。
- [x] `src/main.py` —— Qwen / Flux 图像编辑管线、vanilla 与 GGUF 两档、逐步骤计时回调、PNG 与 CSV 指标输出。
- [x] `src/setup.sh` —— 创建 venv、安装 requirements.txt、PyTorch GPU 冒烟测试。
- [x] `src/Makefile` —— Qwen / Flux 的 vanilla 与 GGUF 多档预置用例目标。
- [x] `src/requirements.txt` —— torch / diffusers / huggingface-hub 等依赖清单，无 AWS SDK 直接依赖。

**关键提取摘要**：
- 基础设施确认华为云 GPU ECS 底座编排完整，provider 未硬编码凭据，terraform.tfvars.example 命名合规。
- 代码层确认为纯 Python 推理工具，无 AWS SDK 调用；推理入口、环境初始化、预置用例、依赖清单逻辑完整保留。

**时间**: 2026-11-09 14:57
**结论**: PASS

## 阶段三 · 迁移溯源与替换取舍必读

- [x] `others/analysis.txt` —— 源仓库功能与文件清单记录，源为纯 Python 推理工具 + EC2 启动脚本，无 AWS SDK 调用。
- [x] `others/license-modification-log.md` —— 上游 MIT 调整为 MIT No Attribution，变更明细记录。
- [x] `others/replacement-suggestions.md` —— 人工决策记录模板与「迁移过程新发现的孤儿文件」结论「无」。

**关键提取摘要**：
- 溯源确认源仓库为纯 Python 推理工具，无 AWS SDK 调用，EC2 启动逻辑由华为云 Terraform 底座完整承载。
- 替换取舍确认许可证调整为 MIT No Attribution（A 类），孤儿文件结论为「无」，与原仓库能力逐条对齐。

**时间**: 2026-11-09 15:00
**结论**: PASS

## 阶段四 · 验证与覆盖声明必读

- [x] `others/verification-report.md` —— T4 V1 结构；基础设施 / 服务与配置 / 业务功能 / 安全合规四层齐全，含静态核查命令与结果，整体结论 PASS。
- [x] `others/feature-coverage.md` —— T5 A 档完整声明表，✅ 行均指向真实产物文件，⏭️ 行写明理由，孤儿结论「无」。
- [x] `others/ai-review-report.md` —— C17 通读证据块，零违规形态，覆盖全部 in-scope 文件。
- [x] `others/verification-report.md` 第 4.3 节 —— 静态核查命令（py_compile / bash -n / grep）与本环境真实执行结果一致。

**关键提取摘要**：
- 验证报告确认 T4 四层齐全且整体 PASS，业务层静态核查命令与结果据实填写，端到端 GPU 推理由部署方按 README §9 强制手测。
- AI 通读与功能覆盖确认 C17 零违规、T5 A 档全部 ✅ 指向真实文件，无静默文件丢失。

**时间**: 2026-11-09 15:02
**结论**: PASS

## 阶段五 · 许可证必读

- [x] `LICENSE` —— MIT No Attribution（Copyright Huawei Cloud），与上游许可证兼容（A 类）。
- [x] `others/license-modification-log.md` —— 许可证溯源记录，确认由上游 MIT 调整为 MIT No Attribution。

**关键提取摘要**：
- 许可证确认根 LICENSE 为 MIT No Attribution，属 A 类（MIT-0），兼容直接迁移。
- 溯源记录确认许可证变更明细已登记在产品文件之外，符合溯源卫生要求。

**时间**: 2026-11-09 15:04
**结论**: PASS
