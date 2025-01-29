output "website_url" {
  value = aws_s3_bucket_website_configuration.dev_s3_website_configuration.website_endpoint
}