variable "instance_type" {
  type        = string
  description = "set AWS instance type"
  default     = "t2.nano"
}
variable "aws_common_tag" {
  type        = map(any)
  description = "set aws tag"
  default = {
    Name = "ec2-petclinic"
  }
}
variable "pvt_key" {
  type    = string
  default = "./ssh-petclinic.pem"
}
variable "ec2-user" {
  type    = string
  default = "ec2-user"
}
