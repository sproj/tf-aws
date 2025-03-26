# Meta-roles for the initial development phase
# These roles are intentionally permissive for ease of development
# They will be restricted once all resource-specific roles are working correctly

# Creator role - Used during initial setup and resource creation
resource "aws_iam_role" "infrastructure_creator" {
  name = "infrastructure-creator-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
      }
    ]
  })

  tags = {
    Name        = "InfrastructureCreatorRole"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach permissive policy to creator role for development
resource "aws_iam_role_policy_attachment" "creator_power_user" {
  role       = aws_iam_role.infrastructure_creator.name
  policy_arn = "arn:aws:iam:aws:policy/PowerUserAccess"
}

# Manager role - Used to manage existing resources
resource "aws_iam_role" "infrastructure_manager" {
  name = "infrastructure-manager-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
      }
    ]
  })

  tags = {
    Name        = "InfrastructureManagerRole"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach permissive policy to manager role for development
resource "aws_iam_role_policy_attachment" "manager_power_user" {
  role       = aws_iam_role.infrastructure_manager.name
  policy_arn = "arn:aws:iam:aws:policy/PowerUserAccess"
}

# Reader role - Used for read-only access to resources
resource "aws_iam_role" "infrastructure_reader" {
  name = "infrastructure-reader-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
      }
    ]
  })

  tags = {
    Name        = "InfrastructureReaderRole"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Attach read-only policy to reader role
resource "aws_iam_role_policy_attachment" "reader_readonly" {
  role       = aws_iam_role.infrastructure_reader.name
  policy_arn = "arn:aws:iam:aws:policy/ReadOnlyAccess"
}