pipeline {
    agent any
   
    environment {
        DOCKER_USERNAME = "safuvanh"
        NODE_IP = "172.31.9.48"
        EC2_NAME = "ubuntu"
        PIPELINE_NAME = "java"
        PROJECT_NAME = "DevOps_Main_Project-1"     
    }

    stages {
        stage("1. Cleanup") {
            
            steps {
                deleteDir ()             
            }
        }

        stage ('2. Git Checkout') {
            
            steps {
                dir ("DevOps_Main_Project-1"){
                  script {
                    git branch: 'main', url: 'https://github.com/safuvanh/DevOps_Main_Project-1.git' 
                  }
                }
            }
        }   
        
        stage("3. Maven Unit Test") {  
            
            steps{
                dir ("DevOps_Main_Project-1"){
                  sh 'mvn test'        
                }
            }
        }

        stage('4. Maven Build') {
            
            steps{
                dir ("DevOps_Main_Project-1"){
                  sh 'mvn clean install'   
                }
            }
        }

        stage("5. Maven Integration Test") {
            
            steps{
                dir ("DevOps_Main_Project-1"){
                  sh 'mvn verify'          
                }
            }
        }

        stage('6. Docker Image Build') {

            steps{
                dir('DevOps_Main_Project-1') {    
                    script {
                      def JOB = env.JOB_NAME.toLowerCase()           
                      sh "docker build -t ${JOB}:${BUILD_NUMBER} ."  
                    }
                }
            }
        }
        
        stage('7. Docker Image Tag') {
            
            steps{
                dir('DevOps_Main_Project-1') {      
                  script {
                    def JOB = env.JOB_NAME.toLowerCase()
                    sh "docker tag ${JOB}:${BUILD_NUMBER} ${DOCKER_USERNAME}/${JOB}:latest"
                  }
                }
            } 
        }

        stage('8. Trivy Image Scan') {
            
            steps{
                script { 
                  def JOB = env.JOB_NAME.toLowerCase() 
                  sh "trivy image ${DOCKER_USERNAME}/${JOB}:latest > scan.txt"
                }
            }
        }

        stage('9. Docker Image Push') {
            
            steps{
                script { 
                  withCredentials([usernamePassword(credentialsId: 'my_dockerhub_creds', usernameVariable: 'docker_user', passwordVariable: 'docker_pass')]) {
                    sh "docker login -u '${docker_user}' -p '${docker_pass}'"
                    def JOB = env.JOB_NAME.toLowerCase() 
                    sh "docker push ${DOCKER_USERNAME}/${JOB}:latest"
                  }
                }
            }
        }

        stage('10. Docker Image Cleanup') {
         
            steps{
                script { 
                  sh "docker image prune -af"
                }
            }
        }
        
        stage("11. Push Files to Node Server") {
            
            steps {
              sshagent(['my_ec2_creds']) {         
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP}"
                sh "scp /var/lib/jenkins/workspace/${PIPELINE_NAME}/${PROJECT_NAME}/deployment.yaml ${EC2_NAME}@${NODE_IP}:/home/ubuntu"
                sh "scp /var/lib/jenkins/workspace/${PIPELINE_NAME}/${PROJECT_NAME}/service.yaml ${EC2_NAME}@${NODE_IP}:/home/ubuntu"
              }
            }
        }
        
        stage('12. Approval') {
      
            steps {
                input message: 'Approve deployment?'
            }
        }

        stage("13. Deployment") {
         
            steps {
              sshagent(['my_ec2_creds']) {          
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP}" 
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP} kubectl apply -f deployment.yaml"
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP} kubectl apply -f service.yaml"
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP} kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
                sh "ssh -o StrictHostKeyChecking=no ${EC2_NAME}@${NODE_IP} kubectl get service"
              }
            }
        }
    }
}
