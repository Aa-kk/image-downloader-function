variable "region" {
    description = "The AWS region to deploy to"
    type        = string
    default     = "eu-central-1"
}

variable "function_name" {
    description = "The name of the function to provision"
    type        = string
    default     = "image-downloader"
}

