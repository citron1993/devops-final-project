pipeline {
    //version '2.0'
    agent any

    environment {
        TF_IN_AUTOMATION = 'true'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        TERRAFORM_DIR = 'terraform'
        TERRAFORM_EXE = 'C:\\terraform\\terraform.exe'
        INVENTORY_FILE = 'inventory.ini'
    }

    parameters {
        string(name: 'AWS_REGION', defaultValue: 'eu-north-1', description: 'AWS region for the website server')
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
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir(env.TERRAFORM_DIR) {
                        bat "\"${env.TERRAFORM_EXE}\" init"
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir(env.TERRAFORM_DIR) {
                        bat """
                            "${env.TERRAFORM_EXE}" plan ^
                              -var="aws_region=${params.AWS_REGION}" ^
                              -var="project_name=${params.PROJECT_NAME}" ^
                              -var="key_name=${params.KEY_NAME}" ^
                              -out=tfplan
                        """
                    }
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
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    dir(env.TERRAFORM_DIR) {
                        bat "\"${env.TERRAFORM_EXE}\" apply -auto-approve tfplan"
                    }
                }
            }
        }

        stage('Build Ansible Inventory') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    bat """
                        for /f %%i in ('"${env.TERRAFORM_EXE}" output -raw public_ip') do set PUBLIC_IP=%%i
                        echo [web] > ..\\${env.INVENTORY_FILE}
                        echo %PUBLIC_IP% ansible_user=ubuntu >> ..\\${env.INVENTORY_FILE}
                    """
                }
            }
        }

        stage('Configure Website') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: params.SSH_PRIVATE_KEY_CREDENTIALS_ID,
                        keyFileVariable: 'SSH_KEY_FILE',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    bat """
                        copy "%SSH_KEY_FILE%" ansible_key.pem >NUL
                        powershell -NoProfile -Command "$p=$env:WORKSPACE -replace '\\\\','/'; $p=$p -replace '^([A-Za-z]):','/mnt/$($matches[1].ToLower())'; Set-Content -Path workspace_wsl.txt -Value $p"
                        set /p WORKSPACE_WSL=<workspace_wsl.txt
                        wsl -d Ubuntu bash -lc "cd \\"%WORKSPACE_WSL%\\" && mkdir -p ~/.ssh && cp ansible_key.pem ~/.ssh/devops-course-key.pem && chmod 600 ~/.ssh/devops-course-key.pem && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${env.INVENTORY_FILE} --private-key ~/.ssh/devops-course-key.pem -u %SSH_USER% ansible/site.yml"
                        if errorlevel 1 (
                            del ansible_key.pem
                            del workspace_wsl.txt
                            exit /b 1
                        )
                        del ansible_key.pem
                        del workspace_wsl.txt
                    """
                }
            }
        }

        stage('Validate Website') {
            steps {
                dir(env.TERRAFORM_DIR) {
                    bat """
                        for /f %%i in ('"${env.TERRAFORM_EXE}" output -raw website_url') do set SITE_URL=%%i
                        curl --fail --retry 10 --retry-delay 6 "%SITE_URL%"
                        echo Website is available at %SITE_URL%
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
