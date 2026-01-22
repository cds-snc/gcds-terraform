module "cdn_origin" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.10.2"
  bucket_name       = "${var.product_name}-${var.env}-cdn"
  billing_tag_value = var.billing_code

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_policy" "cdn_origin" {
  bucket = module.cdn_origin.s3_bucket_id
  policy = data.aws_iam_policy_document.cdn_origin_combined.json
}

data "aws_iam_policy_document" "cdn_origin_combined" {
  source_policy_documents = [
    data.aws_iam_policy_document.cloudfront_get_object.json
  ]
}

data "aws_iam_policy_document" "cloudfront_get_object" {
  statement {
    sid    = "CloudFrontGetObject"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cdn.iam_arn]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${module.cdn_origin.s3_bucket_arn}/*",
    ]
  }
}

# Bucket to store cloudfront logs
module "cloudfront_logs" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.6.8"
  bucket_name       = "${var.product_name}-${var.env}-cdn-logs"
  billing_tag_value = var.billing_code

  versioning = {
    enabled = true
  }
}

resource "aws_s3_bucket_replication_configuration" "s3_replicate_data_lake" {
  role   = aws_iam_role.s3_replicate_data_lake.arn
  bucket = module.cloudfront_logs.s3_bucket_id

  rule {
    id     = "send-to-platform-data-lake"
    status = var.env == "production" ? "Enabled" : "Disabled"

    destination {
      bucket = var.platform_data_lake_raw_s3_bucket_arn
    }
  }
}

# Bucket policy to allow CloudFront to write logs
resource "aws_s3_bucket_policy" "cloudfront_logs_policy" {
  bucket = module.cloudfront_logs.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${module.cloudfront_logs.s3_bucket_id}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })

}

# Set the bucket ownership controls of the log bucket to ensure that CloudFront can write logs
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_ownership_controls" {
  bucket = module.cloudfront_logs.s3_bucket_id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [module.cloudfront_logs]
}

#
# Replicate the data to the Platform Data Lake
#
resource "aws_iam_role" "s3_replicate_data_lake" {
  name               = "DesignSystemS3ReplicatePlatformDataLake"
  assume_role_policy = data.aws_iam_policy_document.s3_replicate_assume.json
}

resource "aws_iam_policy" "s3_replicate_data_lake" {
  name   = "DesignSystemS3ReplicatePlatformDataLake"
  policy = data.aws_iam_policy_document.s3_replicate_data_lake.json
}

resource "aws_iam_role_policy_attachment" "s3_replicate_data_lake" {
  role       = aws_iam_role.s3_replicate_data_lake.name
  policy_arn = aws_iam_policy.s3_replicate_data_lake.arn
}

data "aws_iam_policy_document" "s3_replicate_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "s3.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "s3_replicate_data_lake" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    resources = [
      module.cloudfront_logs.s3_bucket_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl"
    ]
    resources = [
      "${module.cloudfront_logs.s3_bucket_arn}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    resources = [
      "${var.platform_data_lake_raw_s3_bucket_arn}/*"
    ]
  }
}