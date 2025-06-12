variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "public_subnet2" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "private_subnet2" {
  type = string
}

variable "vpc_aws_az" {
  default = "us-east-1a"
}

variable "vpc_aws_az-2" {
  default = "us-east-1b"
}

variable "key_name"{
  type = string
}

variable db_name {
  type = string
}

variable db_username {
  type = string
}

variable db_password {
  type = string
}

