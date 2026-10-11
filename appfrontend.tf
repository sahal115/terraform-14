# -----------------------------
# S3 bucket for static frontend
# -----------------------------

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "terraform.dnc.beauty"
}

# Block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}


# -----------------------------
# CloudFront Origin Access Control
# -----------------------------

resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "terraform-dnc-beauty-oac"
  description                       = "OAC for terraform.dnc.beauty S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# -----------------------------
# CloudFront Distribution
# -----------------------------

resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"

  aliases = ["terraform.dnc.beauty"]

  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "s3-terraform.dnc.beauty"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-terraform.dnc.beauty"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # AWS Managed-CachingOptimized policy
    cache_policy_id = "09a5b4af-22ed-4c56-a413-4dfdf8dc7d65"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.wildcard.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}


# -----------------------------
# S3 bucket policy for CloudFront OAC
# -----------------------------



resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.s3_oac_policy.json
}


# -----------------------------
# Route 53 DNS
# -----------------------------

resource "aws_route53_record" "frontend_dns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "terraform.dnc.beauty"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
