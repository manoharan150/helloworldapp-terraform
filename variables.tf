variable "tenant_ocid" {
  description = "Tenant's OCID"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaaqiz3fvwylh562q5clh7wnlf5anngoniuqqfmzarr6ew3kh5szppq"
}

variable "region" {
  description = "default region"
  type        = string
  default     = "us-ashburn-1"
}

variable "instance_shape" {
  description = "default shape for all instances"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ocpus" {
  default = 1
}

variable "instance_shape_config_memory_in_gbs" {
  default = 6
}

variable "soruce_image_ocid" {
  description = "Source image OCID"
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaalharp53tw6htht7hirwa5vohbu6td5ddhevsaidpeisspwmcm6fq"
}

variable "rsa_public_key_path" {
  description = "RSA Public key content"
  type        = string
  default     = "D:/DevOps/Oracle/SSH/app/ssh-key.key.pub"
}