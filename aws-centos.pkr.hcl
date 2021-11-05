
variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  access_key    = var.access_key
  secret_key    = var.secret_key
  ami_name      = "packer-ub-jenkins"
  instance_type = "t2.medium"
  region        = "eu-west-3"
  source_ami    = "ami-0f7cd40eac2214b37"
  ssh_username  = "ubuntu"
  associate_public_ip_address = true
}

build {
  name    = "packer-centos-v2"
  sources = ["source.amazon-ebs.ubuntu"]
  
  provisioner "file" {
    destination = "/tmp/jenkins_conf.sh"
    source      = "./jenkins_conf.sh"
  }

  provisioner "file" {
    destination = "/tmp/Dockerfile"
    source      = "./Dockerfile"
  }

  provisioner "shell" {
    inline = [
      "sudo su",
      "cd /tmp",
      "sudo chmod +x jenkins_conf.sh",
      "sudo bash ./jenkins_conf.sh"
    ]
  }
}
