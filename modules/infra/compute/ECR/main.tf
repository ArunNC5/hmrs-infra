resource "aws_ecr_repository" "hmrs_np_app_repo" {
  name = "hmrs_np_app_repo"

  image_scanning_configuration {
    scan_on_push = true
  }
}


