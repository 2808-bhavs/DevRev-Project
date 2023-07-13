resource "aws_api_gateway_rest_api" "ftb_terraform" {
  name = "flight_ticket_booking_system"
  description =  "flight_ticket_booking"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    "Author"  = "Bhavya Sree"
    "Project" = "flight_ticket_booking"
  }
}


# .............. creating resources ..........................

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
  parent_id   = aws_api_gateway_rest_api.ftb_terraform.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "flight_booking" {
  rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "flight"
}

#..................... API Key ..................................................

resource "aws_api_gateway_api_key" "api-key-ftb" {
  name = "x-api-key-ftb"
}

data "aws_cloudwatch_log_group" "lambda" {
  count = var.create && var.create_function && !var.create_layer && var.use_existing_cloudwatch_log_group ? 1 : 0

  name = "/aws/lambda/${var.lambda_at_edge ? "us-east-1." : ""}${var.function_name}"
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = var.create && var.create_function && !var.create_layer && !var.use_existing_cloudwatch_log_group ? 1 : 0

  name              = "/aws/lambda/${var.lambda_at_edge ? "us-east-1." : ""}${var.function_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.cloudwatch_logs_kms_key_id

  tags = merge(var.tags, var.cloudwatch_logs_tags)
}