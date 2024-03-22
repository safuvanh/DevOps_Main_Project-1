resource "aws_security_group" "my_security_group2" {
  name        = "my-security-group2"
  description = "Allow K8s ports"

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
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
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
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
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


resource "aws_instance" "my_ec2_instance2" {
  ami                    = "ami-007020fd9c84e18c7"  #ubuntu
  instance_type          = "t2.medium" # K8s requires min 2CPU & 4G RAM
  vpc_security_group_ids = [aws_security_group.my_security_group2.id]
  key_name               = "RHEL9"

  # Consider EBS volume 30GB
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "NODE-SERVER"
  }

  user_data = <<-EOF
    #!/bin/bash
    # wait for 1min before EC2 initialization
    sleep 60
    apt update -y
    wget https://github.com/safuvanh/DevOps_Main_Project-1/raw/main/kube.sh
    chmod +x kube.sh
    ./kube.sh
    systemctl enable --now kubelet

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
      "sudo kubeadm init  --pod-network-cidr=192.168.0.0/16  --ignore-preflight-errors Swap",
      "sudo mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml",
      "sudo kubectl taint nodes --all node-role.kubernetes.io/control-plane-",
      "sudo systemctl restart kubelet",
    ]
  }

}

output "NODE_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ec2_instance2.public_ip
}

output "NODE_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ec2_instance2.private_ip
}
