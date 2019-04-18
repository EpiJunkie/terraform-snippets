
data "aws_region" "current" {}

resource "aws_s3_bucket" "remote_state_s3" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": ${jsonencode(var.list_of_restricted_s3_resource_arns)},
      "Condition": {
        "StringNotLike": {
          "aws:userId": ${jsonencode(keys(var.dict_of_approved_userids))}
        }
      }
    }
  ]
}
POLICY

  versioning {
    enabled = true
  }

  lifecycle_rule {
    prefix                                 = "${var.s3_expire_previous_versions_prefix}"
    enabled                                = "${var.s3_expire_previous_versions_bool}"
    abort_incomplete_multipart_upload_days = 1

    noncurrent_version_expiration {
      days = "${var.s3_expire_previous_versions_period}"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  lifecycle_rule {
    prefix                                 = "${var.s3_transition_previous_versions_to_glacier_prefix}"
    enabled                                = "${var.s3_transition_previous_versions_to_glacier_bool}"
    abort_incomplete_multipart_upload_days = 1

    noncurrent_version_transition {
      days          = "${var.s3_transition_previous_versions_to_glacier_period}"
      storage_class = "GLACIER"
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  tags {
    Description = "${var.s3_bucket_description}"
  }

  lifecycle {
    # prevent_destroy / terraform lifecycle options can not be variabilized
    # See: https://github.com/hashicorp/terraform/issues/3116
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "remote_state_s3" {
  bucket = "${aws_s3_bucket.remote_state_s3.id}"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "remote_state_dynamodb" {
  name = "${var.dynamodb_name}"
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags {
    Description = "${var.dynamodb_description}"
  }
}

data "template_file" "example_remote_state_resource" {
  template = "${file("${path.module}/backend.tf_template")}"
  vars = {
    s3_bucket_name = "${var.s3_bucket_name}"
    dynamodb_name  = "${var.dynamodb_name}"
    aws_region     = "${data.aws_region.current.name}"
  }
}

resource "null_resource" "local" {
  triggers {
    template = "${data.template_file.example_remote_state_resource.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.example_remote_state_resource.rendered}\" > backend.tf_example_`date +%F_%H%M%S`"
  }
}
