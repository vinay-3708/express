terraform {
  backend "s3" {
		bucket   = "my-tf-state-bucket2"
		key      = "terraform.tfstate"
		region   = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
}

resource "aws_ecs_service" "expressjs-svc" {
	cluster = "my-cluster"
	name = "expressjs-svc"
	launch_type = "FARGATE"
	platform_version = "LATEST"
	task_definition = aws_ecs_task_definition.expressjs-task-def.arn
	scheduling_strategy = "REPLICA"
	desired_count = 1
	wait_for_steady_state = true
	load_balancer {
		target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:834117679684:targetgroup/EXPRESSJS-tg/a9ffe37cae807af8"
		container_name   = "expressjs-hello-world"
		container_port   = 3000
    }
	network_configuration {
		assign_public_ip = true
        security_groups  = [
            "sg-0d991c83b056c4635",
        ]
		subnets = [
			"subnet-0f65077084cd5f5af",
			"subnet-0283486c6a37195b2",
			"subnet-0e4cb4e2a4dbdf9a7",
			"subnet-0446fc9af60a01051",
			"subnet-03310ced2349c37b1",
			"subnet-0d238e91b727578a0"
			]
	}

}

resource "aws_ecs_task_definition" "expressjs-task-def" {
    container_definitions    = jsonencode(
        [
            {
                cpu          = 0
                environment  = []
                essential    = true
                image        = "834117679684.dkr.ecr.us-east-1.amazonaws.com/expressjs-hello-world:${var.VERSION}"
                mountPoints  = []
                name         = "expressjs-hello-world"
                portMappings = [
                    {
                        containerPort = 3000
                        hostPort      = 3000
                        protocol      = "tcp"
                    },
                ]
                volumesFrom  = []
            },
        ]
    )
    cpu                      = "512"
    execution_role_arn       = "arn:aws:iam::834117679684:role/ecsTaskExecutionRole"
    family                   = "expressjs-task-def"
    memory                   = "1024"
    network_mode             = "awsvpc"
    requires_compatibilities = [
        "FARGATE",
    ]
    tags                     = {}
    runtime_platform {
        cpu_architecture        = "X86_64"
        operating_system_family = "LINUX"
    }
}
