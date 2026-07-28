resource "aws_lambda_function" "megadetector_sorter" { # "aws_lambda_function" = fester Ressourcentyp vom AWS-Provider
  # "megadetector_sorter" = frei wählbarer interner Name
  function_name = "camtrap-sorter-megadetector" # echter AWS-Name
  package_type  = "Image"                       # wichtig: sagt Lambda, dass ein Container-Image genutzt wird, keine ZIP
  image_uri     = "${aws_ecr_repository.megadetector.repository_url}:latest" # verweist auf das gepushte Image

  role = aws_iam_role.lambda_sorter.arn # verweist auf die IAM-Rolle aus vorherigem Todo

  timeout     = 60   # Sekunden; MegaDetector-Inferenz braucht mehr Zeit als Standard-3s
  memory_size = 2048 # MB; PyTorch/MegaDetector braucht spürbar mehr als Standard-128MB

  tags = {
    Project = "camtrap-sorter"
    Purpose = "image-classification"
  }
}