data "aws_acm_certificate" "wildcard" {
  domain      = var.cert_domain
  statuses    =    ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "primary" {
  name         = var.hosted_zone_name
  private_zone = false
}






data "aws_iam_policy_document" "s3_oac_policy" {
# Create an access statement inside the policy document
statement {
# Define execution permissions for retrieving objects
actions = ["s3:GetObject"]
# Specify the target S3 bucket object ARN pattern
resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]
# Restrict principal strictly to the CloudFront service
principals {
# Set principal type to AWS Service
type = "Service"
# Specify CloudFront service endpoint as principal
identifiers = ["cloudfront.amazonaws.com"]
}
# Restrict permission condition to this specific CloudFront Distribution ARN
condition {
# Require matching AWS Source ARN
test = "StringEquals"
# Specify the source condition key evaluated by IAM
variable = "AWS:SourceArn"
# Pass the CloudFront distribution ARN created above
values = [aws_cloudfront_distribution.frontend_cdn.arn]
}
}
}