# Ways to secure Terraform

There are a few ways to manage sensitive information in Terraform files. Here are some of the most common methods:

## Use the sensitive attribute

- Terraform provides a sensitive attribute that can be used to mark variables and outputs as sensitive. When a variable or output is marked as sensitive, Terraform will not print its value in the console output or in the state file.

## Secret management system

- Store sensitive data in a secret management system. A secret management system is a dedicated system for storing sensitive data, such as passwords, API keys, and SSH keys. Terraform can be configured to read secrets from a secret management system, such as HashiCorp Vault or AWS Secrets Manager.

## Remote Backend

- Encrypt sensitive data. The Terraform state file can be encrypted to protect sensitive data. This can be done by using a secure remote backend, such as Terraform Cloud or S3.

## Environment Variables

- Use environment variables. Sensitive data can also be stored in environment variables. Terraform can read environment variables when it is run.

Here are some specific examples of how to use these methods:

To mark a variable as sensitive, you would add the sensitive attribute to the variable declaration. 

For example:

variable "aws_access_key_id" {
  sensitive = true
}

To store sensitive data in a secret management system, you would first create a secret in the secret management system. Then, you would configure Terraform to read the secret from the secret management system. 

For example, to read a secret from HashiCorp Vault, you would use the vault_generic_secret data source.

data "vault_generic_secret" "aws_access_key_id" {
  path = "secret/aws/access_key_id"
}

variable "aws_access_key_id" {
  value = data.vault_generic_secret.aws_access_key_id.value
}

-example

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
