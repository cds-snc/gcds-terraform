# S3 bucket to host website redirect from alpha EN domain to canonical CA EN domain

module "alpha_en_redirect_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.6.2"
  bucket_name       = var.alpha_domain_redirect_en
  billing_tag_value = var.billing_code

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  # Enable static website hosting with routing rules to redirect all requests
  routing_rules = jsonencode([
    {
      Condition = {
        KeyPrefixEquals = ""
      }
      Redirect = {
        Protocol         = "https"
        HostName         = var.ca_domain_website_en
        ReplaceKeyPrefixWith = ""
      }
    }
  ])
}

# Bucket policy: optional open read access is not needed because CloudFront/Amp is not reading; the bucket is only for website redirect
# No policy needed; S3 website redirect handles client-side HTTP redirect responses.
