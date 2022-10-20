resource "random_string" "this" {
  length  = 4
  special = false
}

locals {
  name = "${var.name}-${random_string.this.result}"
}

resource "aws_secretsmanager_secret" "prisma_cloud_install_bundle" {
  name                    = "${local.name}-install_bundle"
  description             = "Prisma Cloud Defender INSTALL_BUNDLE"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "prisma_cloud_install_bundle" {
  secret_id     = aws_secretsmanager_secret.prisma_cloud_install_bundle.id
  secret_string = var.defender_install_bundle
}

resource "aws_secretsmanager_secret" "prisma_cloud_registry_token" {
  name                    = "${local.name}-reg-creds"
  description             = "Prisma Cloud registry credentials"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "prisma_cloud_registry_token" {
  secret_id     = aws_secretsmanager_secret.prisma_cloud_registry_token.id
  secret_string = <<EOF
{
  "username" : "prismacloud",
  "password" : "${var.prisma_cloud_registry_token}"
}
EOF
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name}-task_execution_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "password_policy_secretsmanager" {
  name = "${local.name}-secretsmanager-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_secretsmanager_secret.prisma_cloud_install_bundle.arn}",
          "${aws_secretsmanager_secret.prisma_cloud_registry_token.arn}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecs_task_definition" "this" {
  family = local.name

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<EOF
[
  {
    "secrets": [{
      "name": "INSTALL_BUNDLE",
      "valueFrom": "${aws_secretsmanager_secret.prisma_cloud_install_bundle.arn}"
    }],
    "environment" : [
      {
        "name" : "DEFENDER_LISTENER_TYPE",
        "value" : "none"
      },
      {
        "name" : "DEFENDER_TYPE",
        "value" : "ecs"
      },
      {
        "name" : "DEFENDER_CLUSTER",
        "value" : ""
      },
      {
        "name" : "DOCKER_CLIENT_ADDRESS",
        "value" : "/var/run/docker.sock"
      },
      {
        "name" : "LOG_PROD",
        "value" : "true"
      },
      {
        "name" : "WS_ADDRESS",
        "value" : "${var.prisma_cloud_ws_address}"
      },
      {
        "name" : "HOST_CUSTOM_COMPLIANCE_ENABLED",
        "value" : "true"
      }
    ],
    "mountPoints" : [
      {
        "containerPath" : "/var/lib/twistlock",
        "sourceVolume" : "data-folder"
      },
      {
        "containerPath" : "/var/run",
        "sourceVolume" : "docker-sock-folder"
      },
      {
        "readOnly" : true,
        "containerPath" : "/etc/passwd",
        "sourceVolume" : "passwd"
      },
      {
        "containerPath" : "/run",
        "sourceVolume" : "iptables-lock-folder"
      },
      {
        "containerPath" : "/dev/log",
        "sourceVolume" : "syslog-socket"
      }
    ],
    "memory" : ${var.defender_memory},
    "volumesFrom" : [],
    "image" : "${var.defender_image}",
    "repositoryCredentials": {
      "credentialsParameter": "${aws_secretsmanager_secret.prisma_cloud_registry_token.arn}"
    },
    "essential" : true,
    "readonlyRootFilesystem" : true,
    "privileged" : true,
    "name" : "twistlock_defender"
  }
]
EOF

  memory                   = var.defender_memory
  requires_compatibilities = ["EC2"]
  network_mode             = "host"
  pid_mode                 = "host"
  volume {
    name      = "data-folder"
    host_path = "/var/lib/twistlock/"
  }

  volume {
    name      = "docker-sock-folder"
    host_path = "/var/run"
  }

  volume {
    name      = "syslog-socket"
    host_path = "/dev/log"
  }

  volume {
    name      = "passwd"
    host_path = "/etc/passwd"
  }

  volume {
    name      = "iptables-lock-folder"
    host_path = "/run"
  }

}

resource "aws_ecs_service" "this" {
  name            = local.name
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "EC2"

  scheduling_strategy = "DAEMON"

}