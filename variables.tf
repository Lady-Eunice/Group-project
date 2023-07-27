variable "region" {
  type = string
  default = "eu-west-2"
}

variable "state" {
    default = "state"
}

# VPC Production
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "vpc cidr block"
}

variable "pub-sub1-cidr" {
    type = string
    default = "10.0.1.0/24"
    description = "public 1 cidr block"
}

variable "pub-sub2-cidr" {
    type = string
    default = "10.0.2.0/24"
    description = "public 2 cidr block"
}
variable "prvt-sub1-cidr" {
    type = string
    default = "10.0.3.0/24"
    description = "priv 1 cidr block"
}

variable "prvt-sub2-cidr" {
    type = string
    default = "10.0.4.0/24"
    description = "priv 2 cidr block"
}