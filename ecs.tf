resource "aws_ecs_cluster" "nodejs_cluster" {
  name = "nodejs-cluster"
}

resource "aws_ecs_task_definition" "nodejs_task" {
  family                   = "nodejs-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "nodejs-app"
      image     = "${aws_ecr_repository.nodejs_repo.repository_url}:latest"
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
        interval    = 30
        retries     = 3
        startPeriod = 60
      }
    }
  ])
}

resource "aws_ecs_service" "nodejs_service" {
  name            = "nodejs-service"
  cluster         = aws_ecs_cluster.nodejs_cluster.id
  launch_type     = "EC2"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.nodejs_task.arn
}
