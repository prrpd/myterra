variable "ami" {
  type        = string
  default     = "ami-0fb653ca2d3203ac1"
  description = "AMI to use"
}

variable "instanceCount" {
  type        = number
  default     = 2
  description = "number of VMs to create"
}
