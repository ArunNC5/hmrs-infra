output "hmrs_np_image_repo" {
  value = "${aws_ecr_repository.hmrs_np_app_repo.id}"
}
output "hmrs_np_image_repo_url" {
  value = "${aws_ecr_repository.hmrs_np_app_repo.repository_url}"
}
