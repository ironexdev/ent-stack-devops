variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the first public subnet"
  type        = string
}

variable "public_subnet2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
}

variable "private_subnet1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
}

variable "private_subnet2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
}

variable "availability_zone1" {
  description = "The first availability zone"
  type        = string
}

variable "availability_zone2" {
  description = "The second availability zone"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region_shorthand" {
  description = "The shorthand name of the region"
  type        = string
}
