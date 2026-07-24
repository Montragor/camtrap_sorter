resource "aws_s3_bucket" "raw_images" { # "raw_images" = dein frei wählbarer interner Name, nur zur Referenz im eigenen Code
  bucket = "camtrap-sorter-raw"         # Der echte AWS-Name, weltweit eindeutig, erscheint so in der AWS Konsole

  tags = {
    Project = "camtrap-sorter-upload"
    Purpose = "raw-image-upload"
  }
}

resource "aws_s3_bucket" "processed_images" {

  bucket = "camtrap-sorter-processed"

  tags = {
    Project = "camtrap-sorter"
    Purpose = "sorted-image-output"
  }

}

resource "aws_s3_bucket" "frontend" {
  bucket = "camtrap-sorter-frontend"

  tags = {
    Project = "camtrap-sorter"
    Purpose = "frontend-hosting"
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid = "PublicReadGetObject"

        Effect = "Allow"

        Principal = "*"

        Action = "s3:GetObject"

        Resource = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]
}

