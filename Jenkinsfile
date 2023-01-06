pipeline {
    agent {
      node {
        label "master"
      } 
    }
    //Setting my default path
    environment {
        PATH = "/usr/local/bin:${env.PATH}"
    }
    //Ensuring go is installed 
    tools {go '1.19'}
        
    stages {
      stage('Testing') {
        steps {
          sh '''
              cd ./test 
              go test -v terraform_infr_test.go -timeout 10m
            '''
        }
      }

      stage('Terraform Apply') {
        steps {
          sh '/usr/bin/terraform apply -auto-approve'
        }
      }     
    } 
  }