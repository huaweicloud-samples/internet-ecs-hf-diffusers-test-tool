# 许可证修改溯源记录（License Modification Log）

> **本文件为内部过程产物，不随华为云最佳实践对外发布。**
> 用途：本 skill 默认将每个迁移产物的根 `LICENSE` 统一替换为 **MIT No Attribution（Copyright Huawei Cloud）**（见 SKILL.md 约束 C12）。
> 本文件逐仓库记录「上游许可证是什么 → 被统一改成了什么 → 依据是什么」，供合规审查与溯源（应对未来需要核查派生关系、恢复上游许可证或回应 license 质询的情形）。

## 适用规则（C12）

- 产物根 `LICENSE` 一律使用 skill 模板 **MIT No Attribution（Copyright Huawei Cloud）**，由 `setup-migration.sh` 复制生成，**不得**因上游许可证类型而改写根 LICENSE。
- 上游许可证的溯源（含 copyleft 的署名 / 变更声明、上游版权等合规信息）**只记入本文件**，不写入产品源文件、`docs/`、`infra/`、`src/`、README。
- 即使上游为 copyleft（GPL 等），根 LICENSE 同样替换为 MIT No Attribution——派生 / 合规责任通过本文件留存证据，产品侧不残留任何上游许可证或来源署名。

## 记录模板

| 日期 | 上游仓库 | 上游许可证（实测） | 上游 LICENSE 位置 | 产物根 LICENSE | 修改动作 | 依据 | 备注 |
|-|-|-|-|-|-|-|-|
| YYYY-MM-DD | `<repo-name>` | `<Apache-2.0 / GPL-2.0 / MIT / MIT-0 / 未检测到 LICENSE>` | `<aws/<repo>/LICENSE 或 README 徽章>` | MIT No Attribution (Huawei Cloud) | 上游 LICENSE → MIT-0 替换 | SKILL.md C12 | `<copyleft 署名要求等注意事项>` |

## 记录

| 日期 | 上游仓库 | 上游许可证（实测） | 上游 LICENSE 位置 | 产物根 LICENSE | 修改动作 | 依据 | 备注 |
|-|-|-|-|-|-|-|-|
| 2026-10-19 | sample-aws-ec2-hf-diffusers-test-tool | MIT No Attribution | /Users/zhangcheng/WorkBuddy/2026-10-19-14-47-39/aws/sample-aws-ec2-hf-diffusers-test-tool/LICENSE | MIT No Attribution (Huawei Cloud) | 上游 LICENSE → MIT-0 替换 | SKILL.md C12 | <备注> |

<!-- 每个迁移仓库按上方模板追加一行。setup-migration.sh 已尽力预填首行；若探测不到上游 LICENSE，将 <UPSTREAM_LICENSE> 置为「未检测到 LICENSE」，请在阶段 1 人工核对补全（检测 aws/<repo>/ 下 LICENSE*/COPYING* 文件或 README 许可证徽章）。 -->
