# DevOps Real-Time Automated Project

## Overview

**This project is a demonstration of Fully automated End-to-End DevOps workflow for deploying and managing a cloud-native application using a variety of tools and technologies including GitHub, Terraform, AWS, Ansible, Jenkins, Maven, Trivy, Docker,Cri-o and Kubernetes.** <br><br>

![444](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/a06591b0-6dae-4ede-9f49-f2b1bbb81eff)





## Prerequisites

**Before getting started, ensure you have the following installed:**

- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://aws.amazon.com/cli/)
  
## Steps:

1.  **Install Terraform and AWS CLI and configure it on your local machine**

    ![Screenshot (372)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/223b743a-5382-4091-9157-00e16c775d59)

2. **Navigate to Project Directory and enter the command `terraform init` for terraform initialization**
     <br><br>
    ![Screenshot (435)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/7e1352cd-439b-40b9-9458-f31a695ab5d8)
     <br><br>
  **- Apply Terraform configuration: `terraform apply --auto-approve`**
     <br><br>
    ![Screenshot (436)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/f87d43c3-3663-4d13-8962-996ef577a92e)
     <br><br>
    ![Screenshot (437)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/804f1a28-645a-4a80-8704-1740abf15d9f)
     <br><br>
3.**Connect to Masternode  via ssh and enter this command for admin password**<br><br>
                                                                    
     ```
     sudo cat /var/lib/jenkins/secrets/initialAdminPassword
     ```
  **- Access Jenkins through web browser and set it up.** <br><br>
   ![Screenshot (439)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/398aefe8-45d3-475d-a678-3a7bf8f221ff)<br><br>
  **- Establish passwordless connection between 'Master-Server' & 'Node-Server'**

     ```
      <Commands to run in 'Node-Server'>
     sudo su -
     passwd ubuntu                           # (set password)
     vi /etc/ssh/sshd_config                 # (Allow 'PermitRootLogin yes' & allow 'PasswordAuthentication yes')
     service sshd restart

       <Commands to run in 'Master-Server'>
     ssh-keygen                              # (this will generate ssh key, press enter when prompted)
     ssh-copy-id ubuntu@<Node_Private_IP>    # (enter 'yes' when prompted & enter the Node's ubuntu password when prompted)
     ```
 - **Note : if permission denied when copying ssh-id ,then copy the public key from `.ssh/id_rsa.pub`  and login in to Node-server  and navigate the directory `.ssh/authorized_keys` and save the public key here, corresponding private key needed for jenkins Credentials while remote login to node server**
      <br><br>
   ![Screenshot (443)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/fb425ae3-d0c1-4b79-8974-2473711d49c0)
 
4. **Access Jenkins portal & add credentials in Jenkins portal as below:** <br><br>
     ```
      (Manage Jenkins --> Credentials --> System --> Global credentials)

     a. Dockerhub credentials - username & password (Use 'secret text' & save them separately)
     b. K8s server username with private key (Use 'SSH Username with private key')
     c. Add Github username & token (Generate Github token & save as 'secret key' in Jenkins server)
      (Github: Github settings --> Developer settings --> Personal Token classic --> Generate)
     d. Dockerhub token (optional) (Generate token & save as 'secret key')
       (Dockerhub: Account --> Settings --> Security --> Generate token & copy it)

     ```
   ![Screenshot (444)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/5e2b4080-163c-419b-b5e2-103cd993747a)<br><br>

 **- Add required plugins in Jenkins portal**
     
     ```
     (Manage Jenkins --> Plugins --> Available plugins --> 'ssh agent' --> Install)
     (This plugin is required to generate ssh agent syntax using pipeline syntax generator)
     ```
    ![Screenshot (445)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/8d03388e-4945-48e7-8556-ca6fc77b942f)<br>
5. **Build Pipeline for Maven Build, Docker Image Build, and Deployment:** <br><br>
    ![Screenshot (450)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/93b5e858-50da-4337-956b-c0d6dfda9670)
     <br><br>
    **- Configure Jenkins pipeline to:** <br>
      **- Perform Maven build from the master server.** <br>
      **- Build Docker image and push to Docker Hub.** <br>
      **- Image Scanning by trivy** <br>
      **- Deploy the application to the Kubernetes node via SSH agent.** <br>
      **- Apply Kubernetes manifest files.** <br>
      **- Expose the application via NodePort for access.** <br><br>
    ![Screenshot (446)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/9d7b4bc3-4284-4569-9e05-7c08d2b0a4ad)<br><br>
  **- Run the pipeline** <br><br>
    ![Screenshot (448)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/04b76049-9a1c-4974-89fa-c80d51c3c3fc)
      <br><br>
    ![Screenshot (449)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/b457ccda-5f2a-45b7-9423-dc517d8fc0a5)<br>
6. **Accessing the Application:** <br>
    **- Once the deployment is successful, obtain the output to access the application.**
    **- Access the application using the NodePort** <br><br>
    ![Screenshot (452)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/c57a0023-a9ab-446e-aa6b-220952be40a6)<br><br>
    ![Screenshot (453)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/dfc957c9-0dd9-4b94-a0e7-127163049ca9)<br><br>

   **- Check the pods are running properly From Node server** <br><br>
    ![image](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/84b3dae5-2232-45a2-9690-c3ad066b2a96)<br><br>

       
    **- Automate the pipeline if any changes are pushed to Github**
   
        ```
       (Webhook will be created in Github & trigger will be created in Jenkins)
       Jenkins --> Configure --> Build triggers --> 'Github hook trigger for GitSCM polling' --> Save
       Jenkins --> <Your_Account> --> Configure --> API Tokens --> <Jenkins-API-Token>
       Github --> <Your-Repo> --> Settings --> Webhooks --> "<Jenkins-url>:8080/github-webhook/"; -->
       Content type: json;     Secret: <Jenkins-API-Token> --> Add Webhook
       (Try making any changes in your code & the pipeline should automatically trigger)
        ```
       <br><br>
    ![Screenshot (456)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/f9545d91-564e-44d8-b65d-0775dd907c9e)
       <br><br>
    ![Screenshot (457)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/ae5bd8b7-c963-4a71-b31f-d2d6a5b88dda)
       <br>
 8. **Destroy all**

    ![Screenshot (458)](https://github.com/safuvanh/DevOps_Main_Project-1/assets/156053146/1f486feb-8013-4251-8bec-b7137a935f9c)
   
  ## Conclusion

   **In summary, this project showcases a streamlined DevOps workflow utilizing leading tools like GitHub, Terraform, AWS, Ansible, Jenkins, Maven, Trivy, Docker, and Kubernetes. By automating infrastructure setup, CI/CD pipelines, and Kubernetes deployments, we've demonstrated efficiency and scalability in cloud-native application management.**
       <p>
   **Embracing automation and best practices in DevOps fosters rapid delivery and high-quality software. This project serves as a foundation for teams to enhance collaboration, productivity, and innovation in their software delivery pipelines. Continued customization and optimization ensure ongoing success in DevOps endeavors.**
   
  


       
  




      
     
 

  


   


