resource "aws_s3_bucket" "raw_images" { # "raw_images" = dein frei wählbarer interner Name, nur zur Referenz im eigenen Code
  bucket = "camtrap-sorter-raw" # Der echte AWS-Name, weltweit eindeutig, erscheint so in der AWS Konsole

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

