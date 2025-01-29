# Module to manage the static website files.
module "website_files" {
  source = "../website"
}

# The s3 bucket for the (dev) environment.
resource "aws_s3_bucket" "dev_s3" {
  bucket = var.dev_bucket
}

# The policy for the (dev) s3 buket to allow public read access.
resource "aws_s3_bucket_policy" "dev_s3_policy" {
  depends_on = [aws_s3_bucket_public_access_block.dev_s3_public_access_block]
  bucket     = aws_s3_bucket.dev_s3.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.dev_bucket}/*"
      }
    ]
  })
}

resource "aws_s3_bucket" "static_website" {
  bucket        = var.dev_bucket
  force_destroy = true
}

# Configuring the (dev) s3 bucket as a static website.
resource "aws_s3_bucket_website_configuration" "dev_s3_website_configuration" {
  bucket = aws_s3_bucket.dev_s3.id

  index_document {
    suffix = "index.html"
  }
}

# This block is uploading the files to the (dev) s3 bucket.
resource "aws_s3_object" "website_files" {
  for_each = fileset("../website", "**/*")

  bucket = aws_s3_bucket.dev_s3.id
  key    = each.value
  source = "../website/${each.value}"
  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "jpeg" = "image/jpeg"
      "gif"  = "image/gif"
    },
    try(regex("\\.([^.]+)$", each.value)[0], ""),
    "application/octet-stream"
  )
}

# Configuring public access settings for the (dev) s3 bucket
resource "aws_s3_bucket_public_access_block" "dev_s3_public_access_block" {
  bucket                  = aws_s3_bucket.dev_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}