resource "aws_ecr_repository" "megadetector" { # "aws_ecr_repository" = fester Ressourcentyp vom AWS-Provider
  # "megadetector" = frei wählbarer interner Name
  name = "camtrap-sorter-megadetector" # echter AWS-Name, muss im Account eindeutig sein

  image_scanning_configuration { # AWS scannt gepushte Images automatisch auf bekannte Sicherheitslücken
    scan_on_push = true
  }

  force_delete = true # erlaubt destroy auch wenn Images im Repository liegen (hier unkritisch, keine Nutzerdaten)

  tags = {
    Project = "camtrap-sorter"
    Purpose = "megadetector-container-image"
  }
}