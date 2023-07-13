#.............................Deployment...............................................

resource "aws_api_gateway_deployment" "ftb_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.ftb_terraform.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_integration.integration_post_user,
    aws_api_gateway_integration.integration_post_book-ticket,
    aws_api_gateway_integration.integration_get_booking,
    aws_api_gateway_integration.integration_get_flight
  ]
  variables = {
      "deployed_at" = "${timestamp()}"
  }
}

resource "aws_api_gateway_stage" "ftb_stage" {
  deployment_id = aws_api_gateway_deployment.ftb_deployment.id
  rest_api_id = aws_api_gateway_rest_api.ftb_terraform.id
  stage_name = "Development"
}

resource "aws_api_gateway_usage_plan" "ftbusageplan" {
  name = "my_usage_plan_ftb"
  api_stages {
    api_id = aws_api_gateway_rest_api.ftb_terraform.id
    stage  = aws_api_gateway_stage.ftb_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api-key-ftb.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.ftbusageplan.id
}
output "name" {
  value = aws_api_gateway_deployment.ftb_deployment.invoke_url
}