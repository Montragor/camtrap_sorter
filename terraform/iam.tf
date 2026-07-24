resource "aws_iam_role" "lambda_sorter" {

  name = "camtrap-sorter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "camtrap-sorter"
    Purpose = "lambda-execution-role"
  }
}


resource "aws_iam_role_policy" "lambda_sorter_permissions" {

  name = "camtrap-sorter-lambda-permissions"

  role = aws_iam_role.lambda_sorter.id


  policy = jsonencode({

    Version = "2012-10-17"


    Statement = [

      {
        Sid = "ReadRawBucket"

        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.raw_images.arn}/*"
      },


      {
        Sid = "WriteProcessedBucket"

        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.processed_images.arn}/*"
      },


      {
        Sid = "WriteLogs"

        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "arn:aws:logs:::*"
      }
    ]
  })
}