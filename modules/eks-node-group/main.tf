# EKS Node Group 모듈
# EKS Managed Node Group 생성

# Launch Template (노드 설정용)
resource "aws_launch_template" "node_group" {
  name_prefix = "${var.cluster_name}-${var.node_group_name}-"
  description = "Launch template for ${var.cluster_name} ${var.node_group_name}"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-${var.node_group_name}-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-${var.node_group_name}-volume"
      }
    )
  }

  user_data = var.user_data_base64

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${var.node_group_name}-lt"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable_percentage = var.max_unavailable_percentage
  }

  launch_template {
    id      = aws_launch_template.node_group.id
    version = "$Latest"
  }

  labels = var.labels

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-${var.node_group_name}"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  depends_on = [
    var.node_role_arn
  ]
}
