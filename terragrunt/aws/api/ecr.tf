resource "aws_ecr_repository" "api" {
  name                 = "${var.product_name}/api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_ecr_lifecycle_policy" "gcds_api_expire_untagged" {
  repository = aws_ecr_repository.api.name
  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Expire untagged images older than 14 days",
        "selection" : {
          "tagStatus" : "untagged",
          "countType" : "sinceImagePushed",
          "countUnit" : "days",
          "countNumber" : 14
        },
        "action" : {
          "type" : "expire"
        }
      },
      {
        "rulePriority" : 2,
        "description" : "Keep last 20 tagged images",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPrefixList" : ["latest"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 20
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}