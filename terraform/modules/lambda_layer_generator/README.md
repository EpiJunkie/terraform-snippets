# lambda_layer_generator

This module creates a Lambda Layer zip package containing unix binaries, Python 3.6 modules, or a terraform binary layer. Uses a base Amazon Linux (v1) image which is the same OS that Lambdas run on their host environment. Then it uploads that zip package as a Lambda Layer resource in AWS.

The `build_type` variable can be set to three valid values: 'unix', 'python36', or 'terraform'.

- 'unix' uses `yum` to download unix binaries and library files for the final Lambda Layer zip package.
- 'python36' uses Python 3.6's `pip` to download modules for the final Lambda Layer zip package.
- 'terraform' uses `wget` to determine the latest stable terraform version and download the Linux binary and repackage it for the final Lambda Layer zip package.

Use the `packages_to_include` variable to specify the, exact `yum` packages when using 'unix' as the `build_type` OR the exact Python 3.6 modules as available in `pip`, desired in the Lambda Layer. If you need to find exactly what packages names to use, run Docker:

```
docker run -it amazonlinux:2017.03 /bin/bash
```

OR an EC2.

**Warning**
> A function can use up to 5 layers at a time. The total unzipped size of the function and all layers can't exceed the unzipped deployment package size limit of 250 MB. For more information, see AWS Lambda Limits.

## Outputs

Output from this module is the same as [aws_lambda_layer_version](https://www.terraform.io/docs/providers/aws/r/lambda_layer_version.html#attributes-reference).

## Example

See `load_modules.tf_example` for complete example.

Example use of Layer module in a `aws_lambda_function` block when the module name is 'example_lambda_layer':

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
