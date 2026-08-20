locals {
    common_tags ={
        Project = var.project
        Name = "${var.project}-${var.environment}"
        Environment = var.environment
    }
    az_zone_name = data.aws_availability_zones.available.names
}