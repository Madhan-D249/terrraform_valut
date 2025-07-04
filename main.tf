provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "vault" {
  address          = "http://65.0.183.113:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "6dcace62-c00d-7205-3e6a-d3989e1f0bc3"
      secret_id = "f0c28395-24af-c7ff-0b82-c8cb8b5c97fa"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "app2/config"
}

resource "aws_instance" "ex" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
    vpc_security_group_ids = var.vpc_security_group_ids

    tags = {
        secret = data.vault_kv_secret_v2.example.data["username"]
    }
}
output "app2_username" {
  value     = data.vault_kv_secret_v2.example.data["username"]
  sensitive = true
}
