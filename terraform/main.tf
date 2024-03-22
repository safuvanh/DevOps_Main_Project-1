provider "aws" {
  region = "ap-south-1"
}
resource "aws_security_group" "my_security_group1" {
  name        = "my-security-group1"
  description = "Allow SSH, HTTP, HTTPS, 8080 for Jenkins & Maven"

  # SSH Inbound Rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_ec2_instance1" {
  ami                    = "ami-007020fd9c84e18c7"  #ubuntu
  instance_type          = "t2.medium"
  vpc_security_group_ids =  [aws_security_group.my_security_group1.id]
  key_name               = "RHEL9"

  # Consider EBS volume 30GB
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "MASTER-SERVER"
  }
  

  user_data = <<-EOF
    #!/bin/bash
    # wait for 1min before EC2 initialization
    sleep 60
    sudo apt update -y  
    sudo apt install default-jdk -y
    sudo apt install maven -y
    sudo apt install docker.io -y
    sudo systemctl enable --now docker

  EOF

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      private_key = file("C:/Users/Safuv/Downloads/RHEL9.pem")
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      # wait for 200sec before EC2 initialization
      "sleep 200",

      "sudo apt install fontconfig openjdk-17-jre -y",

      # Install Jenkins 
     
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",


      "sudo systemctl enable docker",
      "sudo usermod -aG docker jenkins",
      "sudo chmod 666 /var/run/docker.sock",

      # Install Trivy
      
      "wget https://github.com/aquasecurity/trivy/releases/download/v0.50.0/trivy_0.50.0_Linux-64bit.deb",
      "sudo dpkg -i trivy_0.50.0_Linux-64bit.deb",
      "sudo apt install ansible -y",
    ]
  }
}


  output "ACCESS_YOUR_JENKINS_HERE" {
    value = "http://${aws_instance.my_ec2_instance1.public_ip}:8080"
  }

  
  output "MASTER_SERVER_PUBLIC_IP" {
    value = aws_instance.my_ec2_instance1.public_ip
  }

 
  output "MASTER_SERVER_PRIVATE_IP" {
    value = aws_instance.my_ec2_instance1.private_ip
  }
  output "Jenkins_Initial_Password" {
    value = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}
