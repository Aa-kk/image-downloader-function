terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
            
        }
    }
}

provider "aws" {
    region  = var.region
    default_tags {
        tags = {
            Key = "ita_group"
            Value = "Wr-36"
        }   
    }     
}

# Creating IAM Role for lambda function
resource "aws_iam_role" "lambda_image_downloader_role" {
    name = "lambdaa_image_downloader_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid    = ""
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            }
        ]
    })
}

# Attaching S3 access policy to the lambda role
resource "aws_iam_role_policy_attachment" "S3-access-policy" {
    role       = aws_iam_role.lambda_image_downloader_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attaching SQS access policy to the lambda role
resource "aws_iam_role_policy_attachment" "SQSQueue-execution-policy" {
    role       = aws_iam_role.lambda_image_downloader_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Creating Public S3 Bucket for downladed images
resource "aws_s3_bucket" "image_bucket" {
    bucket_prefix = "wr-36-animal-images"
    force_destroy = true
}

# Creating Lambda Function archive/zip file 
data "archive_file" "init" {
    type        = "zip"
    source_dir  = "${path.module}/python"
    output_path = "${path.module}/deployment_package.zip"
}

# Creating Lambda function
resource "aws_lambda_function" "image_downloader_lambda" {
    filename      = "deployment_package.zip"
    function_name = var.function_name
    role          = aws_iam_role.lambda_image_downloader_role.arn
    runtime       = "python3.8"
    handler       = "lambda_function.lambda_handler"
    timeout       = 15
    environment {
        variables = {
        bucket_name = aws_s3_bucket.image_bucket.id
        }
    }
}