variable "zedcloud_token" {
  type      = string
  sensitive = true
}

variable "azure_blob_api_key" {
  type      = string
  sensitive = true
}

variable "azure_blob_api_passwd" {
  type      = string
  sensitive = true
}

variable "s3_api_key" {
  type      = string
  sensitive = true
}

variable "s3_api_passwd" {
  type      = string
  sensitive = true
}

variable "onboarding_key" {
  type      = string
  sensitive = true
}

variable "edgeview_token" {
  type      = string
  sensitive = true
}

variable "ssh_pub_key" {
  type      = string
  sensitive = true
}

variable "ubuntu_image_sha256" {
  type      = string
  sensitive = true
}
