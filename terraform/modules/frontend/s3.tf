# Create S3 bucket
resource "aws_s3_bucket" "website_bucket" {
    bucket = "crctestbucket1"

    tags = {
      Name = "First test tag"
    }
}

# Allow public access - Disabled for now to prepare for CloudFront
resource "aws_s3_bucket_public_access_block" "pab" {
    bucket                  = aws_s3_bucket.website_bucket.id
    block_public_acls       = false
    ignore_public_acls      = false
    block_public_policy     = false
    restrict_public_buckets = false
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.website_bucket.id
    versioning_configuration {
      status = "Enabled"
    }
}

# Website configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
    bucket = aws_s3_bucket.website_bucket.id

    index_document {
      suffix = "index.html"
    }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy"{
    bucket = aws_s3_bucket.website_bucket.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid: "PublicReadGetObject",
			    Effect: "Allow",
			    Principal: "*",
			    Action: "s3:GetObject",
			    Resource = "${aws_s3_bucket.website_bucket.arn}/*"
            }
        ]
    })
}


# --- Objects ---
# Index page
resource "aws_s3_object" "index_html"{
    bucket = aws_s3_bucket.website_bucket.id
    key = "index.html"
    source = "${path.root}/../../../website/index.html"
    content_type = "text/html"
}

resource "aws_s3_object" "index_css"{
    bucket = aws_s3_bucket.website_bucket.id
    key = "styles.css"
    source = "${path.root}/../../../website/styles.css"
    content_type = "text/css"
}

resource "aws_s3_object" "index_js"{
    bucket = aws_s3_bucket.website_bucket.id
    key = "script.js"
    source = "${path.root}/../../../website/script.js"
    content_type = "application/javascript"
}