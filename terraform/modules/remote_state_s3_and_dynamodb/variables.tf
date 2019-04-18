
variable "dict_of_approved_userids" { type = "map"}
variable "list_of_restricted_s3_resource_arns" { type = "list" }
variable "s3_bucket_name" {}
variable "s3_bucket_description" {}
variable "s3_expire_previous_versions_bool" {}
variable "s3_expire_previous_versions_period" {}
variable "s3_expire_previous_versions_prefix" {}
variable "s3_transition_previous_versions_to_glacier_bool" {}
variable "s3_transition_previous_versions_to_glacier_period" {}
variable "s3_transition_previous_versions_to_glacier_prefix" {}
variable "dynamodb_name" {}
variable "dynamodb_description" {}
