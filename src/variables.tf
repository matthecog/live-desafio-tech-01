variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  nullable    = false
}

variable "aws_vpc_name" {
  description = "Name of the VPC"
  type        = string
  nullable    = false
}

variable "aws_eks_name" {
  description = "Name of the EKS cluster"
  type        = string
  nullable    = false
}