pipeline {
    agent any

    environment {
        SONAR_SCANNER_HOME = tool 'sonarscanner'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Binay8025/Ekart.git'
            }
        }
        
       stage('Build & Push to Nexus') {
    steps {
         configFileProvider([
            configFile(fileId: 'global_settings', variable: 'MAVEN_SETTINGS')
        ]) {
            bat 'mvn -s %MAVEN_SETTINGS% clean deploy -DskipTests'
        }
    }
}
      stage('OWASP Dependency Check') {
               steps {
                  dependencyCheck additionalArguments: '--scan target/ --format HTML',
                  odcInstallation: 'owasp' 
                  dependencyCheckPublisher pattern: 'target/dependency-check-report.html'
                }
           }
           
           stage('Upload OWASP Report to Nexus') {
    steps {
        bat """
        curl -u admin:Admin@123456 ^
        --upload-file dependency-check-report.html ^
          http://localhost:8081/repository/security-reports/%JOB_NAME%/%BUILD_NUMBER%/dependency-check-report.html
        """
    }
}

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar') {
                    bat '''
                        "%SONAR_SCANNER_HOME%\\bin\\sonar-scanner"
                        -Dsonar.projectKey=petclinic
                        -Dsonar.projectName=petclinic
                        -Dsonar.java.binaries=target/classes
                        '''
                }
            }
        }
       
        stage('Quality Gate') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        
        stage('sonarqube report to Nexus') {
               steps {
                  bat """
        curl -u admin:Admin@123456 ^
        --upload-file .scannerwork\\report-task.txt ^
          http://localhost:8081/repository/sonar-reports/%JOB_NAME%/%BUILD_NUMBER%/report-task.txt
        """
    }
}

      stage('Trivy Scan - SonarQube Image') {
            steps {
                bat ' docker run -v /docker.sock aquase //var/run/docker.sock:/var/runc/trivy:0.68.2 image --timeout 15m --scanners vuln --skip-dirs /opt/sonarqube/jres --severity HIGH,CRITICAL --format json --output sonarscan-report.json sonarqube:community'
            }
        }   
        
        stage('trivy sonar report to Nexus') {
               steps {
                  bat """
          curl -u admin:Admin@123456 ^
          --upload-file sonarscan-report.json ^
          http://localhost:8081/repository/trivy-reports/%JOB_NAME%/%BUILD_NUMBER%/report-task.json
        """
    }
}
          stage('Build Docker image') {
               steps {
                   script {
                        withDockerRegistry(credentialsId: 'docker-cred', toolName: 'Docker') {
                           bat  'docker build -t petclinic .'
                            
                    }
               } 
          }
    }    
    
          stage('Trivy Scan - Docker Image') {
            steps {
                bat 'docker run -v /docker.sock aquase //var/run/docker.sock:/var/runc/trivy:0.68.2 image --timeout 15m --scanners vuln --format table -o petclinic-alpine-image-report.html petclinic'  
            }
        }   

        stage('trivy docker image report to Nexus') {
               steps {
                  bat """
          curl -u admin:Admin@123456 ^
          --upload-file petclinic-alpine-image-report.html ^
          http://localhost:8081/repository/trivy-reports/%JOB_NAME%/%BUILD_NUMBER%/report-task.json
        """
    }
}
        
          stage('Docker tag & push') {
               steps {
                   script{
                      withDockerRegistry(credentialsId: 'docker-cred', toolName: 'Docker') {
                           bat "docker tag petclinic binay8025/binayp:pet-clinic123:latest "
                           bat 'docker push binay8025/binayp:pet-clinic123:latest'
                    }
               } 
         }
}    
        
         stage('Deploy To Docker Container') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred', toolName: 'Docker') {
                        sh "docker run -d --name petclinic123 -p 8070:8080 binay8025/binayp:pet-clinic123:latest"
                  }
              }
         }
    }
}
