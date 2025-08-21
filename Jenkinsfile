pipeline {
    agent any 
    
    tools{
        jdk 'jdk11'
        maven 'maven3'
    }
    
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    
    stages{
        
        stages {
        stage('Git checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Binay8025/Petclinic.git'
            }
        }
        
        stage("Compile"){
            steps{
                bat "mvn clean compile"
            }
        }
        
         stage("Test Cases"){
            steps{
                bat "mvn test"
            }
        }
        
         stage('Sonar Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar-scanner') {
                         bat """
                              $SCANNER_HOME/bin/sonar-scanner \
                              -Dsonar.url=https://urban-carnival-g459rgx5v465hww6r-9000.app.github.dev/ \
                              -Dsonar.login=squ_45f5034aecbb7df10cea10d2f66f523aec2984a7 \
                              -Dsonar.projectName=Petclinic \
                              -Dsonar.sources=src \
                              -Dsonar.java.binaries=target/classes \
                              -Dsonar.projectKey=Petclinic
                           
                           """
                  }
                } 
             } 
        }
        
        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan target/', odcInstallation: 'owasp'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        
         stage("Build"){
            steps{
                bat " mvn clean install"
            }
        }

            stage('Nexus deploy') {
            steps {
                 configFileProvider([configFile(fileId: '48daf68d-1992-46dc-9ea8-0299547bf066', variable: 'nexussetting')]) {
                 bat """mvn -s "${nexussetting}" clean deploy -DskipTests=true -Pwar"""
         }
    }
}
        
        stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'my-docker-registry-creds', toolName: 'docker') {
                        
                        bat "docker build -t image1 ."
                        bat "docker tag image1 binay8025/binayp:pet-clinic123:latest "
                        bat "docker push binay8025/binayp:pet-clinic123:latest "
                    }
                }
            }
        }
        
        stage("TRIVY"){
            steps{
                bat " trivy image binay8025/binayp:pet-clinic123:latest"
            }
        }
        
        stage("Deploy To Tomcat"){
            steps{
                sh "cp  /var/lib/jenkins/workspace/CI-CD/target/petclinic.war /opt/apache-tomcat-9.0.65/webapps/ "
            }
        }
    }
}
