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
