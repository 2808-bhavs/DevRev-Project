# # ......................... Creating IAM Role ..........................................................

data "aws_iam_role" "academy_lambda_access"{
  name = "academy_lambda_access"
}

#..................... authorizer ...........................................................

module "authorizer-zip" {
 source = "../modules/terraform-aws-lambda"
 runtime = "python3.9"
 create_function = false
 store_on_s3 = true
 s3_bucket = "my-usage-bucket"
 artifacts_dir  = "s3_folders/authorizer"
 source_path = [
    {
      path = "${path.root}/../src/python/authorizer",
      patterns = ["!src/python/authorizer/__pycache__/?.*",]
    },
    {
      path = "${path.root}/../src/python/models",
      prefix_in_zip = "models",
      patterns = ["!src/python/models/__pycache__/?.*",]
    },
    {
      path = "${path.root}/../src/python/service",
      prefix_in_zip = "service",
      patterns = ["!src/python/service/__pycache__/?.*",]
    }
  ]
}


resource "aws_api_gateway_authorizer" "authorizer_resource" {
  type = "REQUEST"
  name                   = "authorizer_resource"
  rest_api_id            = aws_api_gateway_rest_api.ftb_terraform.id
  authorizer_uri         = aws_lambda_function.authorizer_lambda.invoke_arn
  authorizer_credentials = data.aws_iam_role.academy_lambda_access.arn
  identity_source = "method.request.header.email,method.request.header.password"
  authorizer_result_ttl_in_seconds = "0"

}

resource "aws_lambda_function" "authorizer_lambda" {
  s3_bucket = module.authorizer-zip.s3_object.bucket 
  s3_key = module.authorizer-zip.s3_object.key
  function_name = "api_gateway_authorizer_ftb"
  memory_size = "256"
  timeout = "30"
  role          = data.aws_iam_role.academy_lambda_access.arn
  handler       = "authorizer.lambda_handler"
  runtime       = "python3.9"
  depends_on = [
    module.authorizer-zip
  ]
  layers = [module.lambda_layer.this_lambda_layer_arn,]
  vpc_config {
      subnet_ids = split(",", var.subnet_ids)
      security_group_ids = split(",",var.security_group_ids)
    }
  tags = {
    OWNER = "Bhavya Sree"
    PROJECT = "flight_ticket_booking"
    RUN-TIME = "Pyhton-3.9"
    REGION_NAME = "ap-southeast-1"
    }
  environment {
    variables = {
      "host" = var.host,
      "user" = var.user,
      "password" = var.password,
      "database" = var.database,
      "port" = var.port,
      "timeout" = var.timeout,
      "schema" = var.schema
    }
  }
}

# ....................... lambda Permission .............................................

resource "aws_lambda_permission" "lambda-permission-authorizer" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer_lambda.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.ftb_terraform.execution_arn}/authorizers/${aws_api_gateway_authorizer.authorizer_resource.id}"
}
