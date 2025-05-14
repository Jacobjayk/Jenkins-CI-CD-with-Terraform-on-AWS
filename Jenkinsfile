pipeline {
  agent any
  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_CREDS')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_CREDS')
  }
  stages {
    stage('Terraform Init') {
      steps {
        sh 'terraform init'
      }
    }
    stage('Terraform Apply') {
      steps {
        sh 'terraform apply -auto-approve'
      }
    }
  }
}
