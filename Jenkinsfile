pipeline {
     environment {
       ID_DOCKER = "${ID_DOCKER_PARAMS}"
       IMAGE_NAME = "ic-webapp"
       IMAGE_TAG = "latest"
       ODOO_URL = "https://www.gmail.com"
       PGADMIN_URL = "https://www.whitehouse.gov"
       PORT_EXPOSED = "80" //à paraméter dans le job
       STAGING = "${ID_DOCKER}-staging"
       PRODUCTION = "${ID_DOCKER}-production"
       
     }
     agent none
     stages {
       stage('Build image') {
             agent any
             steps {
                script {
                  sh '''
                    git clone https://github.com/EmmanuelGirin/ic-webapp/
                    cd ic-webapp
                    docker build -t ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG .
                    '''
                }
             }
       }

       stage('Scan image with trivy') {
		        agent any
		        steps {
                  sh "trivy image -f json -o results-image.json ${ID_DOCKER}/${IMAGE_NAME}:${IMAGE_TAG}"
                   /* recordIssues(tools: [trivy(pattern: '*.json')]) */
            }
        }

       stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    echo "Clean Environment"
                    docker rm -f $IMAGE_NAME || echo "container does not exist"
                    docker run --name $IMAGE_NAME -d -p ${PORT_EXPOSED}:8080 -e ODOO_URL=${ODOO_URL} -e PGADMIN_URL=${PGADMIN_URL} ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
                    sleep 30
                 '''
               }
            }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                //Test that machine finds the corresponding url for each app
                sh '''
                    curl http://172.17.0.1:${PORT_EXPOSED} | grep ${ODOO_URL}
                    curl http://172.17.0.1:${PORT_EXPOSED} | grep ${PGADMIN_URL}
                '''
              }
           }
       }
    


      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
	       	        echo "Clean du container"
	       	        docker stop ${IMAGE_NAME} && docker rm ${IMAGE_NAME}
          	     '''
              }
          }
      }

     stage ('Login and Push Image on docker hub') {
          agent any
          environment{
            DOCKERHUB_PASSWORD=credentials('DOCKERHUB_PASS')
          }
          steps {
             script {
               sh '''
			          echo $DOCKERHUB_PASSWORD | docker login -u $ID_DOCKER --password-stdin
			          docker push ${ID_DOCKER}/$IMAGE_NAME:$IMAGE_TAG
               '''
             }
          }
        }
  }
} 

stage ("PRODUCTION - Deploy pgadmin") {
steps {
script {
sh '''
export ANSIBLE_CONFIG=$(pwd)/sources/ansible-ressources/ansible.cfg
ansible-playbook sources/ansible-ressources/playbooks/deploy-pgadmin.yml --vault-password-file vault.key -l pg_admin
'''
}
}
}
stage ("PRODUCTION - Deploy odoo") {
steps {
script {
sh '''
export ANSIBLE_CONFIG=$(pwd)/sources/ansible-ressources/ansible.cfg
ansible-playbook sources/ansible-ressources/playbooks/deploy-odoo.yml --vault-password-file vault.key -l odoo
'''
}
}
}

- pip install pyraider
- pyraider check -f app/requirements.txt -e json pyraider.json

- pip install bandit
- bandit -r -f json -o bandit_result.json --exit-zero app/

stage('Scan') {
      agent any
            steps {
                // Install trivy
                sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl > html.tpl'

                // Scan all vuln levels
                sh 'mkdir -p reports'
                sh 'trivy filesystem --ignore-unfixed --vuln-type os,library --format template --template "@html.tpl" -o reports/nodjs-scan.html ./nodejs'
                publishHTML target : [
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports',
                    reportFiles: 'nodjs-scan.html',
                    reportName: 'Trivy Scan',
                    reportTitles: 'Trivy Scan'
                ]

                // Scan again and fail on CRITICAL vulns
                sh 'trivy filesystem --ignore-unfixed --vuln-type os,library --severity CRITICAL ./nodejs'
            }
        }
