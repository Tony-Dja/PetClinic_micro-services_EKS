provider "aws" {
  region     = "eu-west-3"
  access_key = "AKIA44PPB3WEP5ZEZKH7"
  secret_key = "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"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ec2-petclinic" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = "petclinic_terraform_deploy"
  tags                   = var.aws_common_tag
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]
  root_block_device {
    delete_on_termination = true
  }
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${aws_instance.ec2-petclinic.public_ip} ID: ${aws_instance.ec2-petclinic.id} AZ: ${aws_instance.ec2-petclinic.availability_zone} >> infos_ec2-petclinic.txt"
  }
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      agent = false
      user        = var.ec2-user
      private_key = "${file(var.pvt_key)}"
      timeout     = "1m"
    }
    inline = [
      "sudo amazon_linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]
  }
    
  subnet_id = aws_subnet.subnet-uno.id
}

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "petclinic-sg"
  description = "Allow ssh http https inbound traffic"
  vpc_id      = aws_vpc.test-env-petclinic.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eip" "petclinic-aws_eip" {
  instance = aws_instance.ec2-petclinic.id
  domain      = "vpc"
}