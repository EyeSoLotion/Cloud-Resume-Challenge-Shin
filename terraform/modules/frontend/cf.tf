# Create CloudFront Distribution
resource "aws_cloudfront_origin_access_control" "oac" {
    name = "cf-oac"
    description = "CF OAC for S3 Bucket"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
        origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
        origin_id                = "website-origin"
    }

    enabled = true
    default_root_object = "index.html"

    default_cache_behavior {
        target_origin_id = "website-origin"
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }
    }

    # aliases = [ "ishin.portfolio", "www.ishin.portfolio" ]

    viewer_certificate {
        # acm_certificate_arn = Need to create DNS.tf
        ssl_support_method  = "sni-only"
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }
}