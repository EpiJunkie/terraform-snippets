# lambda_layer_generator_unix_binary

This module creates a Lambda Layer zip package containing unix binaries available on a base Amazon Linux (v1) image which is the same OS that Lambdas run on their host environment. Then it uploads that zip package as a Lambda Layer resource in AWS.

Use the `yum_packages_to_include` variable to specify the exact `yum` packages desired in the Lambda Layer. If you need to find exactly what packages names to use, run Docker:

```
docker run -it amazonlinux:2017.03 /bin/bash
```

OR an EC2.

**Warning**
> A function can use up to 5 layers at a time. The total unzipped size of the function and all layers can't exceed the unzipped deployment package size limit of 250 MB. For more information, see AWS Lambda Limits.

## Outputs

Output from this module is the same as [aws_lambda_layer_version](https://www.terraform.io/docs/providers/aws/r/lambda_layer_version.html#attributes-reference).

Use the following in a `aws_lambda_function` block when the module name is 'example_lambda_layer':

```
resource "aws_lambda_function" "example" {
 # ... other Lambda function configuration ...
 layers = ["${module.example_lambda_layer.arn}"]
}
```

# Resources

- https://aws.amazon.com/premiumsupport/knowledge-center/lambda-linux-binary-package/
- https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html
- https://docs.aws.amazon.com/lambda/latest/dg/API_PublishLayerVersion.html#SSS-PublishLayerVersion-request-CompatibleRuntimes
- https://hub.docker.com/_/amazonlinux/
