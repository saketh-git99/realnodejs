# S3 bucket for storing artifacts
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "codepipeline-artifact-nodejs"
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policies to allow CodeBuild access
resource "aws_iam_policy_attachment" "codebuild_policy_attach" {
  name       = "codebuild-policy-attach"
  roles      = [aws_iam_role.codebuild_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# AWS CodeBuild Project
resource "aws_codebuild_project" "build_project" {
  name         = "nodejs-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }

  environment {
    compute_type     = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ECR_REPO_URI"
      value = aws_ecr_repository.nodejs_repo.repository_url
    }
  }

  source {
    type     = "GITHUB"
    location = "https://github.com/saketh-git99/realnodejs"

    buildspec = <<-EOF
    version: 0.2
    phases:
      pre_build:
        commands:
          - echo Logging in to Amazon ECR...
          - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPO_URI
      build:
        commands:
          - echo Building the Docker image...
          - docker build -t $ECR_REPO_URI:latest .
          - docker tag $ECR_REPO_URI:latest $ECR_REPO_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
      post_build:
        commands:
          - echo Pushing Docker image to ECR...
          - docker push $ECR_REPO_URI:latest
          - docker push $ECR_REPO_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION
          - echo Writing image definitions file...
          - printf '[{"name":"nodejs-app","imageUri":"%s"}]' "$ECR_REPO_URI:$CODEBUILD_RESOLVED_SOURCE_VERSION" > imagedefinitions.json
    artifacts:
      files: imagedefinitions.json
    EOF
  }
}
