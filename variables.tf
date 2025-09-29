variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.small"   
}

variable "key_name" {
  default="assignment1"
  description = "EC2 Key Pair name for SSH"
}