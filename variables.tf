variable "pj_name" {
  description = "The name of the project"
  type        = string
  default     = "lambda-cicd-test-tf"
}

variable "images" {
  description = "The list of images to be used in the lambda function"
  type        = list(string)
  default     = ["app"]
}