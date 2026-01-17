variable "account_id" {
  description = "(Required) The account ID to perform actions on."
  type        = string
}

variable "cbs_satellite_bucket_name" {
  description = "(Required) Name of the Cloud Based Sensor S3 satellite bucket"
  type        = string
}

variable "alpha_domain_cdn" {
  description = "(Required) (Alpha) Domain name of the product's Content Delivery Network"
  type        = string
}

variable "alpha_domain_website_en" {
  description = "(Required) (Alpha) Domain name of the product's English website"
  type        = string
}

variable "alpha_domain_website_fr" {
  description = "(Required) (Alpha) Domain name of the product's French website"
  type        = string
}

variable "env" {
  description = "The current running environment"
  type        = string
}

variable "product_name" {
  description = "(Required) The name of the product you are deploying."
  type        = string
}

variable "region" {
  description = "The current AWS region"
  type        = string
}

variable "billing_code" {
  description = "The billing code to tag our resources with"
  type        = string
}
