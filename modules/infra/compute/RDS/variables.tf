variable "ecs_security_group_ids"{
    description = "List of security group IDs to allow access to RDS"
    type        = list(string)
}

variable "db_subnet_group_ids"{
    description = "List of subnet IDs for RDS subnet group"
    type        = list(string)
}

variable "vpc_id"{}