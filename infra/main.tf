# ============================================================================
# 华为云 GPU 弹性云服务器 + 网络 一键部署
# 用途：在华为云启动一台 GPU 加速型弹性云服务器，预装 Python 运行环境，
#       用于运行基于 diffusers 的图像编辑推理与基准测试工具。
# 资源：VPC / 子网 / 安全组 / 密钥对 / 弹性公网 IP / 弹性云服务器
# ============================================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.70"
    }
  }

  backend "local" {}
}

provider "huaweicloud" {
  region = var.region
  # 凭据经环境变量提供，不在此硬编码（见前置条件）
  # export HW_ACCESS_KEY / HW_SECRET_KEY
}

# ----------------------------------------------------------------------------
# 网络层
# ----------------------------------------------------------------------------

resource "huaweicloud_vpc" "main" {
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr
}

resource "huaweicloud_vpc_subnet" "main" {
  name       = "${var.project_name}-subnet"
  vpc_id     = huaweicloud_vpc.main.id
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
}

resource "huaweicloud_networking_secgroup" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name}"
}

resource "huaweicloud_networking_secgroup_rule" "allow_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_source_cidr
  security_group_id = huaweicloud_networking_secgroup.main.id
}

resource "huaweicloud_networking_secgroup_rule" "allow_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "any"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = huaweicloud_networking_secgroup.main.id
}

# ----------------------------------------------------------------------------
# 密钥对（用于 SSH 登录弹性云服务器）
# ----------------------------------------------------------------------------

resource "huaweicloud_kps_keypair" "main" {
  name       = "${var.project_name}-kp"
  public_key = var.ssh_public_key
}

# ----------------------------------------------------------------------------
# 弹性公网 IP（提供出公网能力：拉取模型 / 软件包 / SSH 登录）
# ----------------------------------------------------------------------------

resource "huaweicloud_vpc_eip" "main" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "${var.project_name}-bw"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

# ----------------------------------------------------------------------------
# 计算层：GPU 加速型弹性云服务器
# ----------------------------------------------------------------------------

resource "huaweicloud_ecs_instance" "gpu" {
  name                = "${var.project_name}-gpu"
  flavor_id           = var.ecs_flavor_id
  image_id            = var.image_id
  availability_zone   = var.availability_zone
  vpc_id              = huaweicloud_vpc.main.id
  security_group_ids  = [huaweicloud_networking_secgroup.main.id]
  key_pair            = huaweicloud_kps_keypair.main.name
  eip_id              = huaweicloud_vpc_eip.main.id
  delete_disks_on_termination = true

  system_disk_type = var.system_disk_type
  system_disk_size = var.system_disk_size

  nics {
    subnet_id = huaweicloud_vpc_subnet.main.id
  }

  user_data = <<-EOT
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive

    echo "[setup] 安装系统依赖"
    apt-get update -y
    apt-get install -y python3 python3-venv python3-pip git gcc g++ make python3-dev

    echo "[setup] 创建虚拟环境与工作目录"
    mkdir -p /opt/diffusers-bench
    python3 -m venv /opt/diffusers-bench/venv
    /opt/diffusers-bench/venv/bin/pip install --upgrade pip

    if [ -n "${var.app_code_url}" ]; then
      echo "[setup] 下载基准测试代码：${var.app_code_url}"
      curl -fsSL "${var.app_code_url}" -o /tmp/app.tar.gz
      tar -xzf /tmp/app.tar.gz -C /opt/diffusers-bench --strip-components=1
    else
      echo "[setup] 未配置代码包 URL，请在部署后通过 SCP 上传 src/ 目录到 /opt/diffusers-bench"
    fi

    echo "[setup] 环境准备完成。登录后执行："
    echo "  source /opt/diffusers-bench/venv/bin/activate"
    echo "  cd /opt/diffusers-bench && pip install -r requirements.txt"
    echo "  python main.py --help"
  EOT

  tags = {
    project = var.project_name
  }
}

# ----------------------------------------------------------------------------
# 输出
# ----------------------------------------------------------------------------

output "vpc_id" {
  description = "私有网络 ID"
  value       = huaweicloud_vpc.main.id
}

output "subnet_id" {
  description = "子网 ID"
  value       = huaweicloud_vpc_subnet.main.id
}

output "ecs_id" {
  description = "弹性云服务器 ID"
  value       = huaweicloud_ecs_instance.gpu.id
}

output "ecs_public_ip" {
  description = "弹性云服务器绑定的弹性公网 IP 地址"
  value       = huaweicloud_vpc_eip.main.address
}
