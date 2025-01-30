output "s3_bucket_name" {
  value = aws_s3_bucket.dev_s3.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.dev_s3_website_configuration.website_endpoint
}