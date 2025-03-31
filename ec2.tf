resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_instance" "ecs_instance" {
  ami                    = "ami-0727cf12519cc2b5b"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs_instance_profile.name
  subnet_id              = element(var.subnet_ids, 0)
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=nodejs-cluster" >> /etc/ecs/ecs.config
              systemctl enable --now ecs.service
              yum install -y aws-cli
              systemctl restart ecs
              EOF
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH for debugging (change for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
