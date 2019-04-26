# S3 web with cloudfront
## Bucket
resource "aws_s3_bucket" "web-s3-bucket" {
  bucket = "web-${var.name}-bucket"
  acl    = "public-read"
  region = "${var.region}"

  tags {
    Name        = "web-${var.name}"
    Environment = "${var.environment}"
  }

  versioning {
    enabled = false
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

## Cloudfront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.web-s3-bucket.bucket_regional_domain_name}"

    origin_path = "${var.cloudfront_origin_path}"
    origin_id   = "s3-${var.name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = ""
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = ["${var.url}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-${var.name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Environment = "${var.environment}"
  }

  viewer_certificate {
    acm_certificate_arn = "${var.ssl_arn}"
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "/index.html"
  }
}

## Route 53
resource "aws_route53_record" "web-route" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.url}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
