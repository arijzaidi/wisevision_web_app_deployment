terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.19.0"
    }
  }
}
provider "aws"{
    region = "us-east-1"
}

resource "aws_s3_bucket" "django_bucket" {
  bucket = "my-beanstalk-django-bucket-12345"
}

resource "aws_s3_object" "django_object" {
  bucket = aws_s3_bucket.django_bucket.bucket
  key    = "django-v1.zip" 
  source = "test_wisevision.zip"
}


# resource "aws_instance" "wisevision" {
#     ami = "ami-04b4f1a9cf54c11d0"
#     instance_type = "t2.medium"
#     tags = {
#         Name = "wisevision"
#     }
  
# }

resource "aws_elastic_beanstalk_application" "wisevision" {
    name = "wisevision"
}


resource "aws_elastic_beanstalk_application_version" "django_version" {
  name        = "v1"
  application = aws_elastic_beanstalk_application.wisevision.name
  bucket      = aws_s3_bucket.django_bucket.id
  key         = aws_s3_object.django_object.key
}

resource "aws_elastic_beanstalk_environment" "wisevision" {
  name = "wisevision"
  application = aws_elastic_beanstalk_application.wisevision.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.3.2 running Python 3.12"
  tier = "WebServer"
  version_label = aws_elastic_beanstalk_application_version.django_version.name
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro" 
  }
  
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "test"
  }


  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "aws-elasticbeanstalk-service-role2"
  } 
}

output "url" {
  value = aws_elastic_beanstalk_environment.wisevision.endpoint_url
}
