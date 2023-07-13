locals{
  module_path = "${replace(path.module, "\\","/")}"
}

#....................... account id ........................

variable "accountId" {
  default = "774416584173"
}

#....................... region ............................

variable "region" {
  default = "ap-southeast-1"
}

#........... VPC .....................................................................

variable "subnet_ids" {
  default = "subnet-0011517e161c530f3,subnet-0ff2919169d4d48d7,subnet-025c93f40fbf7e093"
}
variable "security_group_ids" {
  default = "sg-043a40ff9a620d749"
}

#.........................................................................................
locals {
  time = formatdate("DD MMM YYYY hh:mm:ss ZZZ", timestamp())
}

#............................ Environment Variables........................................................

variable "host" {
  default = "database-1.ciqzf7t3wqt1.ap-southeast-1.rds.amazonaws.com"
}

variable "user" {
  default = "postgres"
}

variable "port" {
  default = "5432"
}

variable "password" {
  default = "Vaibhav2002"
}

variable "schema" {
  default = "flight"
}

variable "database" {
  default = "lms_project"
}

variable "timeout" {
  default = "15"
}

variable "s3_bucket" {
  default = "my-usage-bucket"
}


variable "create" {
  description = "Controls whether resources should be created"
  type        = bool
  default     = true
}

variable "create_package" {
  description = "Controls whether Lambda package should be created"
  type        = bool
  default     = true
}

variable "create_function" {
  description = "Controls whether Lambda Function resource should be created"
  type        = bool
  default     = true
}

variable "create_layer" {
  description = "Controls whether Lambda Layer resource should be created"
  type        = bool
  default     = false
}

variable "create_role" {
  description = "Controls whether IAM role for Lambda Function should be created"
  type        = bool
  default     = true
}

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = bool
  default     = false
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda Function runtime"
  type        = string
  default     = ""

  #  validation {
  #    condition     = can(var.create && contains(["nodejs10.x", "nodejs12.x", "java8", "java11", "python2.7", " python3.6", "python3.7", "python3.8", "dotnetcore2.1", "dotnetcore3.1", "go1.x", "ruby2.5", "ruby2.7", "provided"], var.runtime))
  #    error_message = "The runtime value must be one of supported by AWS Lambda."
  #  }
}



variable "use_existing_cloudwatch_log_group" {
  description = "Whether to use an existing CloudWatch log group or create new"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = null
}

variable "cloudwatch_logs_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data."
  type        = string
  default     = null
}

variable "cloudwatch_logs_tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
locals {
  module = "${replace(path.module, "\\", "/")}"
}