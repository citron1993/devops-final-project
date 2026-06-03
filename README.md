# מטלת סיכום DevOps

פרויקט זה מדגים Pipeline מלא ב-Jenkins שמקים אתר אינטרנט בענן בעזרת Terraform ו-Ansible.

## מה הפרויקט עושה

1. Jenkins מושך את הקוד מ-GitHub.
2. Terraform מקים שרת EC2 ב-AWS, Security Group וכתובת ציבורית.
3. Jenkins מייצר Inventory עבור Ansible לפי כתובת השרת.
4. Ansible מתקין Nginx ומעלה אתר סטטי.
5. Jenkins מבצע בדיקת ולידציה שהאתר זמין דרך HTTP.

## מבנה התיקיות

```text
.
├── Jenkinsfile
├── ansible/
│   └── site.yml
├── docs/
│   └── protocol.md
├── site/
│   └── index.html
└── terraform/
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    └── terraform.tfvars.example
```

## דרישות מקדימות

- חשבון AWS עם הרשאות ליצירת EC2 ו-Security Groups.
- Jenkins נגיש מהאינטרנט או מהרשת שבה עובדים.
- Jenkins עם הכלים הבאים מותקנים: Git, Terraform, Ansible, AWS CLI ו-Curl.
- Credentials ב-Jenkins:
  - `aws-access-key-id`
  - `aws-secret-access-key`
  - `aws-ec2-ssh-key`
- Key Pair קיים ב-AWS בשם `devops-course-key`.

## הגדרת Jenkins

1. יוצרים Pipeline Job חדש.
2. מגדירים SCM ל-GitHub repository של הפרויקט.
3. מגדירים את ה-repository branch ל-`main`.
4. מגדירים Script Path:

```text
Jenkinsfile
```

5. מריצים את ה-Pipeline עם הפרמטרים:

```text
AWS_REGION = eu-north-1
PROJECT_NAME = devops-final-site
KEY_NAME = devops-course-key
SSH_PRIVATE_KEY_CREDENTIALS_ID = aws-ec2-ssh-key
AUTO_APPROVE = true
```

## הרצה מקומית לבדיקה

```bash
cd terraform
terraform init
terraform plan -var='key_name=devops-course-key'
terraform apply -auto-approve -var='key_name=devops-course-key'
cd ..
printf "[web]\n$(cd terraform && terraform output -raw public_ip) ansible_user=ubuntu\n" > inventory.ini
ansible-playbook -i inventory.ini ansible/site.yml
curl "$(cd terraform && terraform output -raw website_url)"
```

## מחיקת המשאבים

בסיום העבודה מומלץ למחוק את המשאבים כדי לא לצבור עלויות:

```bash
cd terraform
terraform destroy -var='key_name=devops-course-key'
```

## בונוסים אפשריים

- הוספת Domain ו-HTTPS.
- שמירת Terraform state ב-S3 עם נעילה ב-DynamoDB.
- הרצת בדיקות HTML כחלק מה-Pipeline.
- שליחת התראה ל-Slack או Email בסיום הרצה.
