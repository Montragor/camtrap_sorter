resource "aws_cognito_identity_pool" "upload_pool" {
  identity_pool_name               = "camtrap-sorter-upload-pool"
  allow_unauthenticated_identities = true
}

resource "aws_iam_role" "cognito_unauthenticated" {
  name = "camtrap-sorter-cognito-unauth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.upload_pool.id
        }
        "ForAnyValue:StringLike" = {
          "cognito-identity.amazonaws.com:amr" = "unauthenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "cognito_unauthenticated_permissions" {
  name = "camtrap-sorter-cognito-unauth-permissions"
  role = aws_iam_role.cognito_unauthenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowUploadToRawBucketOnly"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.raw_images.arn}/*"
      },
      {
        Sid      = "AllowListProcessedBucket" # neu: Auflisten der Dateien erlauben
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.processed_images.arn
      },
      {
        Sid      = "AllowReadProcessedBucket" # neu: Herunterladen der Dateien erlauben
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.processed_images.arn}/*"
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "upload_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.upload_pool.id

  roles = {
    unauthenticated = aws_iam_role.cognito_unauthenticated.arn
  }
}