#resource for get-booking
resource "aws_api_gateway_resource" "get_booking"{
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    parent_id = aws_api_gateway_resource.flight_booking.id
    path_part = "get-booking"
}

#declaring method for resource path V1/library/get-booking
resource "aws_api_gateway_method" "get_booking_method" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = "GET"
    authorization = "CUSTOM"
    authorizer_id = aws_api_gateway_authorizer.authorizer_resource.id
    api_key_required = true

    request_parameters = {
        "method.request.header.email" = true
        "method.request.header.Password" = true
        "method.request.header.x-api-key" = true
    }
    request_validator_id = aws_api_gateway_request_validator.get_booking_validator.id
}

#request validator for get-booking-method
resource "aws_api_gateway_request_validator" "get_booking_validator" {
    name = "get-booking-validator"
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    validate_request_parameters = true
}

#zipping for get-booking code files
module "zip_get_booking" {
  source = "../modules/terraform-aws-lambda"
  runtime = "python3.9"
  create_function = false
  store_on_s3 = true
  s3_bucket = var.s3_bucket
  artifacts_dir  = "s3_files/get-booking"
  source_path = [
    {
      path          = "${path.root}/../src/python/get_booking_details",
      prefix_in_zip = "get_booking_details"
      patterns = [
        "!src/get_booking_details/__pycache__/?.*",
      ]
     },
     {
      path          = "${path.root}/../src/python/service",
      prefix_in_zip = "service"
      patterns = [
        "!src/service/__pycache__/?.*",
      ]
     },
     {
      path          = "${path.root}/../src/python/models",
      prefix_in_zip = "models"
      patterns = [
        "!src/models/__pycache__/?.*",
      ]
     }
  ]
}

#lambda for get author

resource "aws_lambda_function" "lambda_get_booking"{
    function_name = "lambda_get_booking"
    description = "lamda for get-booking method"
    s3_bucket = module.zip_get_booking.s3_object.bucket
    s3_key = module.zip_get_booking.s3_object.key
    memory_size = "256"
    timeout = "30"
    role = data.aws_iam_role.academy_lambda_access.arn
    handler = "get_booking_details/get-booking.lambda_handler"
    runtime = "python3.9"
    layers = [module.lambda_layer.this_lambda_layer_arn,]
    environment{
      variables = {
        host = var.host
        user = var.user
        database = var.database
        password = var.password
        port = var.port
        timeout = var.timeout
      schema = var.schema
      }
    }
    tags = {
    OWNER = "Bhavya Sree"
    PROJECT = "booking_ticket_booking"
    RUN-TIME = "Pyhton-3.9"
    REGION_NAME = "ap-southeast-1"
    }
    vpc_config {
      subnet_ids = split(",", var.subnet_ids)
      security_group_ids = split(",",var.security_group_ids)
    }
    depends_on = [
      module.zip_get_booking
    ]
}

#permission for get-booking lambda
resource "aws_lambda_permission" "lambda_permission_get_booking" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_get_booking.arn
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.ftb_terraform.id}/*/${aws_api_gateway_method.get_booking_method.http_method}${aws_api_gateway_resource.get_booking.path}"
}

#integration request for get-booking

resource "aws_api_gateway_integration" "integration_get_booking" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.lambda_get_booking.invoke_arn
    request_parameters = {
        "integration.request.header.email" = "method.request.header.email"
        "integration.request.header.Password" = "method.request.header.Password"    
        "integration.request.header.x-api-key" = "method.request.header.x-api-key"    
    }
    request_templates = {
    "application/json" = "${file("${local.module}/flight.template")}"
  }
    passthrough_behavior = "WHEN_NO_TEMPLATES"
    timeout_milliseconds = "15000"
}

##################################### 200 RESPONSE #######################################

resource "aws_api_gateway_method_response" "get-booking-200-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = "200"
    response_models = {
        "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration_response" "ir-200-get-booking" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = aws_api_gateway_method_response.get-booking-200-error.status_code

    selection_pattern = "-"
    response_templates = {
      "application/json" = "$input.json('$')"
    }
    depends_on = [
        aws_api_gateway_method_response.get-booking-200-error
    ] 
}

################################### 400 RESPONSE ######################################
resource "aws_api_gateway_method_response" "get-booking-400-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = "400"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-400-get-booking" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = aws_api_gateway_method_response.get-booking-400-error.status_code

    selection_pattern = ".*Invalid request.*"
    response_templates = {
    "application/json" = "$input.path('$.errorMessage')"
  }
    depends_on = [
        aws_api_gateway_integration_response.ir-200-get-booking,
        aws_api_gateway_method_response.get-booking-400-error
    ] 
}

###################################### 404 RESPONSE #################################
resource "aws_api_gateway_method_response" "get-booking-404-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = "404"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-404-get-booking" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = aws_api_gateway_method_response.get-booking-404-error.status_code

    selection_pattern = ".*Author not found.*"
    response_templates = {
    "application/json" = "$input.path('$.errorMessage')"
  }
    depends_on = [
        aws_api_gateway_integration_response.ir-200-get-booking,
        aws_api_gateway_integration_response.ir-400-get-booking,
        aws_api_gateway_method_response.get-booking-404-error
    ] 
}

################################## 500 RESPONSE ######################################
resource "aws_api_gateway_method_response" "get-booking-500-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = "500"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-500-get-booking" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.get_booking.id
    http_method = aws_api_gateway_method.get_booking_method.http_method
    status_code = aws_api_gateway_method_response.get-booking-500-error.status_code

    selection_pattern = ".*Internal server error.*"
    response_templates = {
    "application/json" = "$input.path('$.errorMessage')"
  }
    depends_on = [
        aws_api_gateway_integration_response.ir-200-get-booking,
        aws_api_gateway_integration_response.ir-400-get-booking,
        aws_api_gateway_integration_response.ir-404-get-booking,
        aws_api_gateway_method_response.get-booking-500-error
    ] 
}
