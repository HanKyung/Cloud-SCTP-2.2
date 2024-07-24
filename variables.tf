variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.3.0/16"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.128.0/20", "10.0.144.0/20", "10.0.6.0/16"]
}