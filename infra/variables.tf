# ============================================================================
# 变量定义（弹性云服务器 + 网络 一键部署）
# ============================================================================

variable "region" {
  description = "华为云区域"
  type        = string
  default     = "cn-north-4"
}

variable "project_name" {
  description = "项目名称，用于资源命名前缀"
  type        = string
  default     = "gpu-diffusers-bench"
}

variable "vpc_cidr" {
  description = "私有网络网段"
  type        = string
  default     = "192.168.0.0/16"
}

variable "subnet_cidr" {
  description = "子网网段"
  type        = string
  default     = "192.168.1.0/24"
}

variable "subnet_gateway_ip" {
  description = "子网网关地址"
  type        = string
  default     = "192.168.1.1"
}

variable "availability_zone" {
  description = "可用区（末尾加字母，如 cn-north-4a）"
  type        = string
  default     = "cn-north-4a"
}

variable "ssh_source_cidr" {
  description = "允许 SSH 入站的源 CIDR（建议收敛到运维机 IP，例如 203.0.113.10/32）"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "SSH 公钥内容（id_rsa.pub / id_ed25519.pub 全文），用于登录弹性云服务器"
  type        = string
  sensitive   = true
}

variable "ecs_flavor_id" {
  description = "GPU 加速型弹性云服务器规格（如 p2s.2xlarge.8 / g5.2xlarge.4 / pi2.2xlarge.4）。各区域可选规格不同，部署前请在控制台确认"
  type        = string
  default     = "p2s.2xlarge.8"
}

variable "image_id" {
  description = "公共镜像 ID（需为已预装 NVIDIA 驱动 / CUDA 的 GPU 加速型镜像；也可选用深度学习镜像）。部署前请在控制台确认目标区域存在"
  type        = string
}

variable "system_disk_size" {
  description = "系统盘容量（GiB），模型与依赖较大，建议 ≥ 200"
  type        = number
  default     = 200
}

variable "system_disk_type" {
  description = "系统盘类型"
  type        = string
  default     = "GPSSD"
}

variable "app_code_url" {
  description = "可选：基准测试代码 tarball 的公网 URL。留空则需在部署后手动上传 src/ 目录"
  type        = string
  default     = ""
}
