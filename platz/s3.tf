resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.name_prefix}-access-logs"
}

data "aws_iam_policy_document" "access_logs_bucket" {
  statement {
    actions = ["s3:PutObject"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    resources = [
      "${aws_s3_bucket.access_logs.arn}/${var.name_prefix}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.bucket
  policy = data.aws_iam_policy_document.access_logs_bucket.json
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.bucket

  rule {
    id = "expire-1m"

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}
