# S3 bucket to host website redirect from alpha EN domain to canonical CA EN domain
module "alpha_redirect_bucket_en" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.6.2"
  bucket_name       = var.alpha_domain_redirect_en
  billing_tag_value = var.billing_code
}

# S3 bucket to host website redirect from alpha FR domain to canonical CA FR domain
module "alpha_redirect_bucket_en" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.6.2"
  bucket_name       = var.alpha_domain_redirect_fr
  billing_tag_value = var.billing_code
}


# Configure S3 static website hosting to redirect all requests to the CA EN domain (HTTPS)
resource "aws_s3_bucket_website_configuration" "alpha_redirect_en" {
  bucket = module.alpha_en_redirect_bucket.s3_bucket_id

  redirect_all_requests_to {
    host_name = var.ca_domain_website_en
    protocol  = "https"
  }
}

# Configure S3 static website hosting to redirect all requests to the CA FR domain (HTTPS)
resource "aws_s3_bucket_website_configuration" "alpha_redirect_fr" {
  bucket = module.alpha_fr_redirect_bucket.s3_bucket_id

  redirect_all_requests_to {
    host_name = var.ca_domain_website_fr
    protocol  = "https"
  }
}