variable "ecs_execution_role_arn" {}
variable "repo_url" {}
variable "subnet_ids" {
  type = list(string)
}
variable "vpc_id"{}
variable "pvt_rt_1_id"{}