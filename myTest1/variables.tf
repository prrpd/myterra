variable "ami" {
  type        = string
  description = "AMI to use"
}

variable "instanceCount" {
  type        = number
  default     = 2
  description = "number of VMs to create"
}
