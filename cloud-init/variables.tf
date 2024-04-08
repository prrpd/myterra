variable "ami" {
  type        = string
  default     = "ami-0fb653ca2d3203ac1"
  description = "AMI to use"
}

variable "instanceCount" {
  type        = number
  default     = 1
  description = "number of VMs to create"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "instance type to use"
}

variable "region" {
  type        = string
  description = "region to use"
}
