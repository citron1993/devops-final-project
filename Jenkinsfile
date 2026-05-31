pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        TERRAFORM_DIR = 'terraform'
        INVENTORY_FILE = 'inventory.ini'
    }

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'eu-central-1', description: 'AWS region for the website server')
        string(name: 'PROJECT_NAME', defaultValue: 'devops-final-site', description: 'Project name used for AWS tags')
        string(name: 'KEY_NAME', defaultValue: '', description: 'Existing AWS EC2 key pair name')
        string(name: 'SSH_PRIVATE_KEY_CREDENTIALS_ID', defaultValue: 'aws-ec2-ssh-key', description: 'Jenkins credentials ID for the matching private SSH key')
        booleanParam(name: 'AUTO_APPROVE', defaultValue: true, description: 'Apply Terraform without manual approval')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Parameters') {
            steps {
                script {
                    if (!params.KEY_NAME?.trim()) {
                        error('KEY_NAME is required. Use the name of an existing AWS EC2 key pair.')
                    }
                    if (!params.SSH_PRIVATE_KEY_CREDENTIALS_ID?.trim()) {
                        error('SSH_PRIVATE_KEY_CREDENTIALS_ID is required.')
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh """
                        terraform plan \
                          -var='aws_region=${params.AWS_REGION}' \
                          -var='project_name=${params.PROJECT_NAME}' \
                          -var='key_name=${params.KEY_NAME}' \
                          -out=tfplan
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                script {
                    if (!params.AUTO_APPROVE) {
                        input message: 'Apply Terraform plan?'
                    }
                }
                dir(env.TERRAFORM_DIR) {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Build Ansible Inventory') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh """
                        PUBLIC_IP=\$(terraform output -raw public_ip)
                        echo "[web]" > ../${env.INVENTORY_FILE}
                        echo "\${PUBLIC_IP} ansible_user=ubuntu" >> ../${env.INVENTORY_FILE}
                    """
                }
            }
        }

        stage('Configure Website') {
            steps {
                sshagent(credentials: [params.SSH_PRIVATE_KEY_CREDENTIALS_ID]) {
                    sh "ansible-playbook -i ${env.INVENTORY_FILE} ansible/site.yml"
                }
            }
        }

        stage('Validate Website') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    sh """
                        SITE_URL=\$(terraform output -raw website_url)
                        curl --fail --retry 10 --retry-delay 6 "\${SITE_URL}"
                        echo "Website is available at \${SITE_URL}"
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'inventory.ini,terraform/tfplan', allowEmptyArchive: true
        }
    }
}
