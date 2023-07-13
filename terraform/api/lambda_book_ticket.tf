#resource for book-ticket

resource "aws_api_gateway_resource" "book-ticket"{
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    parent_id = aws_api_gateway_resource.flight_booking.id
    path_part = "book-ticket"
}

#declaring method for resource path V1/library/book-ticket
resource "aws_api_gateway_method" "book-ticket_method" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = "POST"
    authorization = "CUSTOM"
    authorizer_id = aws_api_gateway_authorizer.authorizer_resource.id
    api_key_required = true

    request_parameters = {
        
        "method.request.header.email" = true
        "method.request.header.Password" = true
        "method.request.header.x-api-key" = true
    }
  
    request_validator_id = aws_api_gateway_request_validator.book-ticket_validator.id
}

#request validator for book-ticket-method
resource "aws_api_gateway_request_validator" "book-ticket_validator" {
    name = "book-ticket-validator"
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    validate_request_body = true
    validate_request_parameters = true
}

#zipping for book-ticket
module "zip_post_book-ticket_mv" {
  source = "../modules/terraform-aws-lambda"
  runtime = "python3.9"
  create_function = false
  store_on_s3 = true
  s3_bucket = var.s3_bucket
  artifacts_dir  = "s3_files/book-ticket"
  source_path = [
    {
      path          = "${path.root}/../src/python/book_ticket",
      prefix_in_zip = "book_ticket"
      patterns = [
        "!src/book_ticket/__pycache__/?.*",
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

#lambda for post book-ticket

resource "aws_lambda_function" "lambda_post_book-ticket"{
    function_name = "lambda_post_book_ticket"
    description = "lamda for book-ticket method"
    s3_bucket = module.zip_post_book-ticket_mv.s3_object.bucket
    s3_key = module.zip_post_book-ticket_mv.s3_object.key
    memory_size = "256"
    timeout = "30"
    role = data.aws_iam_role.academy_lambda_access.arn
    handler = "book_ticket/book-ticket.lambda_handler"
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
    PROJECT = "flight_ticket_booking"
    RUN-TIME = "Pyhton-3.9"
    REGION_NAME = "ap-southeast-1"
    }
    vpc_config {
      subnet_ids = split(",", var.subnet_ids)
      security_group_ids = split(",",var.security_group_ids)
    }
    depends_on = [
      module.zip_post_book-ticket_mv
    ]
}

#permission for book-ticket lambda
resource "aws_lambda_permission" "lambda_permission_post_book-ticket" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_post_book-ticket.arn
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.ftb_terraform.id}/*/${aws_api_gateway_method.book-ticket_method.http_method}${aws_api_gateway_resource.book-ticket.path}"
}

#integration request for book-ticket

resource "aws_api_gateway_integration" "integration_post_book-ticket" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    integration_http_method = "POST"
    type = "AWS"
    uri = aws_lambda_function.lambda_post_book-ticket.invoke_arn
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

#################################### 200 RESPONSE #########################################

resource "aws_api_gateway_method_response" "book-ticket-200-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = "200"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-200-book-ticket" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = aws_api_gateway_method_response.book-ticket-200-error.status_code

    selection_pattern = "-"
    response_templates = {
      "application/json" = "$input.json('$')"
    }
    depends_on = [
        aws_api_gateway_method_response.book-ticket-200-error
    ] 
}


################################ 400 RESPONSE #######################################
resource "aws_api_gateway_method_response" "book-ticket-400-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = "400"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-400-book-ticket" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = aws_api_gateway_method_response.book-ticket-400-error.status_code

    selection_pattern = ".*Invalid request.*"
    response_templates = {
      "application/json" = "$input.path('$.errorMessage')"
    }
    depends_on = [
        aws_api_gateway_integration_response.ir-200-book-ticket,
        aws_api_gateway_method_response.book-ticket-400-error
    ] 
}

################################### 500 RESPONSE ##########################################
resource "aws_api_gateway_method_response" "book-ticket-500-error" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = "500"
    response_models = {
        "application/json" = "Empty"
    }  
}

resource "aws_api_gateway_integration_response" "ir-500-book-ticket" {
    rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
    resource_id = aws_api_gateway_resource.book-ticket.id
    http_method = aws_api_gateway_method.book-ticket_method.http_method
    status_code = aws_api_gateway_method_response.book-ticket-500-error.status_code

    selection_pattern = ".*Internal server error.*"
    response_templates = {
      "application/json" = "$input.path('$.errorMessage')"
    }
    depends_on = [
        aws_api_gateway_integration_response.ir-200-book-ticket,
        aws_api_gateway_integration_response.ir-400-book-ticket,
        aws_api_gateway_method_response.book-ticket-500-error
    ] 
}