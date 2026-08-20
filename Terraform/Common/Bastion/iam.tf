resource "aws_iam_role" "bastion" {
  name = "${var.project}-${var.environment}-Bastion_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "Bastion_Role_policy" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "Bastion_Role" {
  name = "${var.project}-${var.environment}-Bastion_Role"
  role = aws_iam_role.bastion.name
}