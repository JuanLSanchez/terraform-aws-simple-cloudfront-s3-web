variable "name" {
  description = "Name of the application"
}

variable "route53_zone_id" {
  description = "Route 53 zone id"
}

variable "environment" {
  description = "Environment [dev, pre, prod]"
}

variable "ssl_arn" {
  description = "Arn of the ssl certificate"
}

variable "url" {
  description = "Url of the app"
}

variable "cloudfront_origin_path" {
  description = "Root path in the bucket for the cloudfront"
  default     = ""
}

variable "region" {
  description = "Region for the bucket"
  default     = "eu-west-1"
}
