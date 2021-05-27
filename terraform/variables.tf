variable "region" {
    default = "us-east-1"
    }
variable "instance" {
    default = "t2.micro"
    }
variable "private_key" {
    default = "Key1.pem"
    }
variable "ansible_user" {
    default = "ubuntu"
    }
variable "PATH_TO_PRIVATE_KEY" {
  default = "~/.ssh/MyKeyPair"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "~/.ssh/MyKeyPair.pub"
}