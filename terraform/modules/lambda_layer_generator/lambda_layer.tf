
resource "aws_lambda_layer_version" "lambda_layer_mysql_unix_binary" {
  # https://www.terraform.io/docs/providers/aws/r/lambda_layer_version.html
  depends_on       = ["null_resource.build_lambda_layer_zip_unix_binary"]
  filename         = "${var.lambda_layer_zip_package_name}"
  layer_name       = "${var.layer_name}"
  description      = "${var.layer_description}"
  license_info     = "${var.layer_license}"

  # https://docs.aws.amazon.com/lambda/latest/dg/API_PublishLayerVersion.html#SSS-PublishLayerVersion-request-CompatibleRuntimes
  compatible_runtimes = "${var.layer_compatibility}"
}

resource "null_resource" "build_lambda_layer_zip_unix_binary" {
  # Builds layer zip by executing commands in Docker env and then pulling produced
  # zip out of docker environment. Only runs when zip is missing or last build
  # variable is changed.
  triggers {
    last_build = "${var.lambda_layer_build_date}"
    packages   = "${var.packages_to_include}"
  }

  provisioner "local-exec" {
    command = "docker build ${path.module}/ -f ${path.module}/Dockerfile -t lambda-layer-generator"
  }

  provisioner "local-exec" {
    command = "docker run -e BUILD_TYPE=\"${var.build_type}\" -e YUM_PACKAGES_TO_INCLUDE=\"${var.packages_to_include}\" -e LAMBDA_LAYER_ZIP_PACKAGE_NAME=\"${var.lambda_layer_zip_package_name}\" lambda-layer-generator | tee /tmp/lambda-layer-generator.log"
  }

  provisioner "local-exec" {
    command = "eval \"`tail -n1 /tmp/lambda-layer-generator.log`\""
  }
}
