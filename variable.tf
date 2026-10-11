variable "vpc-cidr_block" {
  description = "The vpc cidr block"
  type = string
  default = "10.0.0.0/16"
}

variable "region-name" {
    default = var.region
}
  
