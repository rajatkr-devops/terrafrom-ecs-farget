resource "aws_ecr_repository" "ecrrepo" {
  name                 = "${var.name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
}

//ecr lifecycle


resource "aws_ecr_lifecycle_policy" "ecrlf" {
  repository = aws_ecr_repository.ecrrepo.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     description  = "keep last 10 images"
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}

resource "aws_security_group" "ecssecurity" {
  name   = "${var.name}-sg-task-${var.environment}"
  vpc_id = var.vpc_id
 
  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "ecsservice" {
 name                               = "${var.name}-service-${var.environment}"
 cluster                            = aws_ecs_cluster.ecs-cluster.id
 task_definition                    = aws_ecs_task_definition.main.arn
 desired_count                      = 2
 deployment_minimum_healthy_percent = 50
 deployment_maximum_percent         = 200
 launch_type                        = "FARGATE"
 scheduling_strategy                = "REPLICA"
 
 network_configuration {
   security_groups  = [aws_security_group.ecssecurity.id]
   subnets          = var.subnets
   assign_public_ip = true
 }
 
 load_balancer {
   target_group_arn = aws_alb_target_group.target.arn
   container_name   = "${var.name}-container-${var.environment}"
   container_port   = 80
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}