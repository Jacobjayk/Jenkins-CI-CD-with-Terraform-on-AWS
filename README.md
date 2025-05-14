# Project 3: Jenkins CI/CD with Terraform on AWS  
_A Complete Beginner’s Guide (Zero AWS/DevOps Knowledge Required)_

---

## 📌 Before You Start

**You’ll Need:**  
- An **AWS account** (Free Tier is fine)  
- A **GitHub/GitLab account** (to store your code)  
- **30–45 minutes** of setup time


**Avoid These Common Mistakes:**  
- Skipping IAM permissions (Jenkins won’t be able to deploy)  
- Using **t2.micro** for Jenkins (it often runs out of memory—use **t2.medium**)  
- Forgetting to open port **8080** (you won’t reach the Jenkins UI)

---

## 🚀 Step 1: Launch a Jenkins Server

### A. Launch the EC2 Instance
1. Sign in to the **AWS EC2 Console** → **Launch Instance**  
2. Name it **Jenkins-Server**  
3. Choose **Ubuntu 22.04 LTS** (Free Tier eligible)  
4. Select **t2.medium** (≥4 GB RAM)  
5. Create and download a new key pair named **jenkins-key.pem**  
6. In **Security Group**:
   - Allow **SSH** (port 22) from your IP  
   - Allow **Custom TCP** (port 8080) from **0.0.0.0/0**  
7. **Launch** the instance


### B. Install Jenkins
1. Wait ~1 minute, note the instance’s **Public IPv4**  
2. SSH in:  

```bash
ssh -i "jenkins-key.pem" ubuntu@YOUR_INSTANCE_IP
```

Add Jenkins key & repo, install Java 17 & Jenkins:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk curl gnupg
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo \
  "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
```

Get the admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Browse to http://YOUR_INSTANCE_IP:8080, paste the password,
click Install suggested plugins, then Create Admin User.

---

## 🚀 Step 2: Install Terraform & AWS CLI

### A. Install Terraform (HashiCorp APT Repo)
Install prerequisites:

```bash
sudo apt update
sudo apt install -y gnupg software-properties-common curl unzip wget
```

Import GPG key:

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor \
    -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Add HashiCorp repo:

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
```

Install Terraform:

```bash
sudo apt update
sudo apt install -y terraform
terraform --version  # expect v1.7.x or later
```

### B. Install AWS CLI v2
Download & unzip:

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip awscliv2.zip
```

Install & verify:

```bash
sudo ./aws/install
aws --version  # expect aws-cli/2.x.x
```

### C. Configure AWS Credentials
In AWS Console: IAM → Users → Add User

Name: jenkins-terraform-user

Access type: Programmatic

Permissions: Attach AdministratorAccess

Copy the Access Key ID & Secret Access Key

On the server, run:

```bash
aws configure
# Enter Access Key, Secret Key, region (us-west-2), output (json)
```

---

## 🚀 Step 3: Set Up Jenkins Pipeline

### A. Install Required Plugins
In Jenkins UI → Manage Jenkins → Manage Plugins → Available, install:

Pipeline

Terraform

AWS Credentials

Then Restart Jenkins.

### B. Add AWS Credentials to Jenkins
Manage Jenkins → Credentials → System → Global credentials

Add Credentials:

Kind: AWS Credentials

ID: AWS_CREDS

Paste your Access Key & Secret Key

OK

### C. Create & Push Your Terraform Project
On your local machine, in a folder named terraform-aws-demo:

`main.tf`

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web" {
  ami           = "ami-04999cd8f2624f834"
  instance_type = "t2.micro"
  tags = {
    Name = "Jenkins-Deployed-EC2"
  }
}
```

`Jenkinsfile`

```groovy
pipeline {
  agent any
  environment {
    AWS_ACCESS_KEY_ID     = credentials('AWS_CREDS')
    AWS_SECRET_ACCESS_KEY = credentials('AWS_CREDS')
  }
  stages {
    stage('Terraform Init') {
      steps { sh 'terraform init' }
    }
    stage('Terraform Apply') {
      steps { sh 'terraform apply -auto-approve' }
    }
  }
}
```

Commit & push to your GitHub main branch:

```bash
git init
git add main.tf Jenkinsfile
git commit -m "Initial Terraform + Jenkins pipeline"
git branch -M main
git remote add origin <YOUR_GIT_REPO_URL>
git push -u origin main
```

### D. Create the Jenkins Pipeline Job
In Jenkins → New Item → Pipeline, name it terraform-demo.

Under Pipeline:

Definition: Pipeline script from SCM

SCM: Git

Repository URL: <YOUR_GIT_REPO_URL>

Branch Specifier: */main

Save, then Build Now.

---

## 🚀 Step 4: Verify Deployment
Check Jenkins Stage View: all stages should pass.

In AWS EC2 Console (us-west-2), you’ll see an instance named Jenkins-Deployed-EC2 running.

---

## 🚀 Step 5: Clean Up (Optional)
Add a destroy stage to your Jenkinsfile:

```groovy
stage('Terraform Destroy') {
  steps { sh 'terraform destroy -auto-approve' }
}
```

Re-run the pipeline to delete the EC2 instance.

---

## 🔧 Troubleshooting
Issue	Fix
Terraform not found	Verify /usr/local/bin/terraform exists, or reinstall via APT and restart Jenkins.
AWS CLI not found	Ensure /usr/local/bin/aws is on PATH, or reinstall AWS CLI v2.
“InvalidAMIID.NotFound”	Use AMI ami-04999cd8f2624f834 in us-west-2 (or data-behind lookup if preferred).
Build stays “Scheduled”	Check executor count or node labels under Manage Jenkins → Nodes.

---

## 🎉 You Did It!
Now you have:
✅ Automated AWS deployments (No manual clicking!)
✅ Jenkins CI/CD pipeline (Runs on code changes)
✅ Terraform infrastructure-as-code (Reproducible environments)

---

## 👤 Author
Jacob Akotuah

- [📧 LinkedIn](https://www.linkedin.com/in/jacobakotuah/)
- [📝 Dev.to Blog](https://dev.to/jayk)
- [💻 GitHub](https://github.com/Jacobjayk)
