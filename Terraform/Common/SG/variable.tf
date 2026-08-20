variable "project" {
}
variable "environment" {
  
}

variable "sg_names"{
    default = ["mongodb","mysql","redditmq","redis",
                "catalogue","cart","payment","shipping","user",
                "backend-alb",
                "frontend",
                "frontend-alb",
                "bastion"
    ]
}

variable "sg_tags" {
    default = {}
}