locals {
  main_vpc_cidr_block         = "192.168.0.0/16"
  public_subnet_cidr_block_1  = "192.168.0.0/24"
  public_subnet_cidr_block_2  = "192.168.1.0/24"
  private_subnet_cidr_block_1 = "192.168.2.0/24"
  private_subnet_cidr_block_2 = "192.168.3.0/24"
  availability_zone_1         = "us-east-1a"
  availability_zone_2         = "us-east-1b"
  cluster_name                = "eks-app-deployment"
  domain  = "testdomainafd.link"
}