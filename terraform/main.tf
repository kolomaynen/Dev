provider "aws" {
  profile = "default"
  region  = "${var.region}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance}"
  key_name = aws_key_pair.sshkey.key_name
  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}"]

  tags = {
    Name = "Server"
  }

provisioner "remote-exec" {
        inline = ["echo connected"]
        connection {
            type        = "ssh"
            user        = var.INSTANCE_USERNAME
            private_key = file(var.PATH_TO_PRIVATE_KEY)
            host        = aws_instance.web.public_ip
        }
    }

    # SSH готов - запускаем Ansible

    provisioner "local-exec" {
         command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ubuntu@${aws_instance.web.public_ip}, --private-key ${var.PATH_TO_PRIVATE_KEY} provision_web.yaml"
    }
}

resource "aws_instance" "jenkins-ci" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "${var.instance}"
    key_name = aws_key_pair.sshkey.key_name
    vpc_security_group_ids = ["${aws_security_group.web_security_group.id}"]

    tags = {
     Name = "Jenkins"
    }
	provisioner "remote-exec" {
        inline = ["echo connected"]
        connection {
            type        = "ssh"
            user        = var.INSTANCE_USERNAME
            private_key = file(var.PATH_TO_PRIVATE_KEY)
            host        = aws_instance.jenkins-ci.public_ip
        }
    }

    # SSH готов - запускаем Ansible

    provisioner "local-exec" {
         command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ubuntu@${aws_instance.jenkins-ci.public_ip}, --private-key ${var.PATH_TO_PRIVATE_KEY} provision_jenkins-ci.yaml"
    }

}


resource "aws_security_group" "web_security_group"{
        name = "My Security Group"

        ingress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]

        }

        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }

}