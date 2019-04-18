
output "arn" {
  value = "${aws_lambda_layer_version.lambda_layer_mysql_unix_binary.arn}"
}

output "layer_arn" {
  value = "${aws_lambda_layer_version.lambda_layer_mysql_unix_binary.layer_arn}"
}

output "created_date" {
  value = "${aws_lambda_layer_version.lambda_layer_mysql_unix_binary.created_date}"
}

output "source_code_size" {
  value = "${aws_lambda_layer_version.lambda_layer_mysql_unix_binary.source_code_size}"
}

output "version" {
  value = "${aws_lambda_layer_version.lambda_layer_mysql_unix_binary.version}"
}
