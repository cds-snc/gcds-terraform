module "cdn_origin" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.4.4"
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
