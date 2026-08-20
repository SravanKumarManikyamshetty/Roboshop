locals {
    common_tags ={
        Project = var.project
        Name = "${var.project}-${var.environment}"
        Environment = var.environment
    }
}