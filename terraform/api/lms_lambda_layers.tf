module "lambda_layer"{
    source = "../modules/terraform-aws-lambda"
    create_layer = true 
    layer_name = "packages"
    compatible_runtimes = ["python3.9"]
    s3_bucket = var.s3_bucket
    store_on_s3 = true
    artifacts_dir = "s3_files/lambda_layer"
    source_path = {
        pip_requirements = "${path.root}/../requirements.txt",
        prefix_in_zip = "python"
    }
    runtime = "python3.9"
}



