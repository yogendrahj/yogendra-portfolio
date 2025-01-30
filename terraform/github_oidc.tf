# OIDC Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub OIDC thumbprint
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsOIDC"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_oidc.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        "StringEquals" = {
          "token.actions.githubusercontent.com:sub" = "repo:yogendrahj/yogendra-portfolio:ref:refs/heads/*"
        }
      }
    }]
  })
}

# Policy to Allow S3 Upload & CloudFront Invalidation
resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsS3CloudFrontPolicy"
  description = "Allows GitHub Actions to deploy to S3 and invalidate CloudFront cache"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket"],
        Resource = ["arn:aws:s3:::yogendra-tech-portfolio", "arn:aws:s3:::yogendra-tech-portfolio/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["cloudfront:CreateInvalidation"],
        Resource = "arn:aws:cloudfront::216989108476:distribution/E23LBTV90KTZFY"
      },
      # DynamoDB Permissions for Terraform State Locking
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ],
        Resource = "arn:aws:dynamodb:eu-west-2:216989108476:table/tf-state-lock"
      },
      # Allow GitHub Actions to Assume This Role
      {
        Effect = "Allow",
        Action = ["sts:AssumeRoleWithWebIdentity"],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
