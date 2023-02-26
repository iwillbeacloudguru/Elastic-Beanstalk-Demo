module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eb"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  database_subnets = ["10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  enable_dns_hostnames               = true
  enable_dns_support                 = true
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  tags = {
    Terraform   = "true"
    Environment = "Sandbox"
  }
}

resource "aws_security_group" "rds_mysql_sg" {
  name        = "mysql-rds"
  description = "SG for Mysql RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "MySQL Classic Port"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = module.vpc.database_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = "Sandbox"
    name        = "mysql-rds-sg"
  }
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-server"
  description = "SG for Wordpress"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "EFS Port"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    description = "HTTP Port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
