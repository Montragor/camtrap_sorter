resource "aws_lambda_function" "megadetector_sorter" { # "aws_lambda_function" = fester Ressourcentyp vom AWS-Provider
  # "megadetector_sorter" = frei wählbarer interner Name
  function_name = "camtrap-sorter-megadetector"                              # echter AWS-Name
  package_type  = "Image"                                                    # wichtig: sagt Lambda, dass ein Container-Image genutzt wird, keine ZIP
  image_uri     = "${aws_ecr_repository.megadetector.repository_url}:latest" # verweist auf das gepushte Image

  role = aws_iam_role.lambda_sorter.arn # verweist auf die IAM-Rolle aus vorherigem Todo

  timeout     = 180   # Sekunden; MegaDetector-Inferenz braucht mehr Zeit als Standard-3s
  memory_size = 3008 # MB; PyTorch/MegaDetector braucht spürbar mehr als Standard-128MB

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_images.bucket
    }
  }

  tags = {
    Project = "camtrap-sorter"
    Purpose = "image-classification"
  }
}

resource "aws_lambda_permission" "allow_s3" { # erlaubt S3 überhaupt, diese Lambda aufzurufen
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.megadetector_sorter.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_images.arn # nur dieser eine Bucket darf die Funktion triggern
}

resource "aws_s3_bucket_notification" "raw_bucket_trigger" { # legt fest, WANN S3 die Lambda aufruft
  bucket = aws_s3_bucket.raw_images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.megadetector_sorter.arn
    events              = ["s3:ObjectCreated:*"] # löst bei jedem neuen Objekt aus, egal ob Upload/Kopie/Multipart
  }

  depends_on = [aws_lambda_permission.allow_s3] # Berechtigung muss zuerst existieren, sonst schlägt apply fehl
}