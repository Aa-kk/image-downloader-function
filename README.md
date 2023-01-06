# image-downloader-function

_Description_

This repo contains files for deploying a lambda funtion which downloads images and uploads them to an s3 bucket. 
function was triggerred by SQS and recived an input which was in json string that represented two key-value pairs eg. "body": "{\"animal\":\"squirrel\",\"number\":\"2\"}" .
I was working in a group and I was tasked to build the lambda function which pulled messages from SQS sent from a discord bot.

* Terraform code (main.tf)
Whole project was deployed using IaC, this terraform code used the archive_file (zip) resource to deploy the lambda function, hence every terraform pply repacks the deployment_package incase there are any changes.

* Test
Implemented automated infrastructure testing using terratest.

* Continous Deployment (CI/CD)
Using the Jenkins file which automates the test and deploy of the infrastructure in the cloud using a jenkins pipeline.
Pipeline is triggered automatically using git webhooks. 