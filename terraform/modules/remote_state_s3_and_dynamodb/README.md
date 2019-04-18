# remote_state_s3_and_dynamodb module

This module sets up a S3 bucket and DynamoDB table to be used to store the terraform state remotely and also lock that state file when being used by a user or process. When this module is applied, a sample remote state tf file is generated in the project folder.

The S3 bucket is VERY restrictive as IAM credentials or other sensitive data could be store in the state file if terraform is setting up those resources.

The S3 bucket is set up with the following configuration:

- A bucket policy to deny all but white listed users or roles from accessing bucket and/or objects.
- All public access to the bucket is turned off using [bucket level public access blocking](https://aws.amazon.com/blogs/aws/amazon-s3-block-public-access-another-layer-of-protection-for-your-accounts-and-buckets/).
- AES256 encryption of objects is enabled by default on the server side.
- Versioning is enabled.
- Lifecycle to transition previous version to Glacier after specified number of days with control to enable/disable and specify prefix.
- Lifecycle to delete previous version after specified number of days with control to enable/disable and specify prefix.

Example S3 bucket policy to prevent any access to bucket or any objects except for the one user and two roles. This policy even blocks the root user from accessing objects within the bucket. However the root user is still able to change the bucket policy if needed, such as when you lock yourself out by specifying the wrong userids or resources.:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::terraform-remote-state-example",
                "arn:aws:s3:::terraform-remote-state-example/*"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        "AIDAEXAMPLEID",
                        "AROAEXAMPLEID:*",
                        "AROAEXAMPLEID2:123456789012"
                    ]
                }
            }
        }
    ]
}
```

Example S3 bucket policy to prevent access to terraform state file objects except for the one user and two roles specified below. Keep in mind this is **not idea** as any user with access to the bucket could change the policy and then access the state file contents. It is recommended to specify the bucket as one of the resources, like above.:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::terraform-remote-state-example/project1/path/to/terraform.tfstate",
                "arn:aws:s3:::terraform-remote-state-example/project2/path/to/terraform.tfstate"
            ],
            "Condition": {
                "StringNotLike": {
                    "aws:userId": [
                        "AIDAEXAMPLEID",
                        "AROAEXAMPLEID:*",
                        "AROAEXAMPLEID2:123456789012"
                    ]
                }
            }
        }
    ]
}
```

The userids/roleids and resources can be specified in the module by populating `dict_of_approved_userids` and `list_of_restricted_s3_resource_arns` variables respectively. **Keep in mind that getting these wrong might lock you out from accessing the bucket until the root account removes the bucket policy.**

Example generated remote state file:

```
terraform {
  backend "s3" {
    region         = "us-west-2"
    bucket         = "terraform-remote-state-example"
    key            = "s3/prefix/path/to/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-example"
  }
}
```

## Resources

- https://www.terraform.io/docs/backends/types/s3.html
- https://github.com/hashicorp/terraform/issues/3116
