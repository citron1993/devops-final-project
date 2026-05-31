# פרוטוקול עבודה - מטלת סיכום DevOps

## מטרת העבודה

מטרת הפרויקט היא להקים אתר אינטרנט בענן באמצעות תהליך אוטומטי. התהליך מבוצע דרך Jenkins Pipeline ומשלב Terraform להקמת התשתית ו-Ansible להגדרת השרת והאתר.

## רכיבי המערכת

- GitHub: שמירת קוד הפרויקט, התיעוד וקבצי ההגדרה.
- Jenkins: הרצת ה-Pipeline מקצה לקצה.
- Terraform: יצירת שרת EC2, Security Group וחיבורי רשת נדרשים.
- Ansible: התקנת Nginx והעתקת קבצי האתר לשרת.
- AWS EC2: השרת שעליו האתר רץ.

## שלבי הביצוע

1. יצירת repository ב-GitHub והעלאת הקבצים.
2. יצירת Key Pair ב-AWS לצורך התחברות SSH לשרת.
3. הגדרת credentials ב-Jenkins עבור AWS ועבור מפתח SSH.
4. יצירת Pipeline Job ב-Jenkins שמצביע על ה-repository.
5. הרצת Jenkinsfile:
   - Checkout מה-repository.
   - Terraform init.
   - Terraform plan.
   - Terraform apply.
   - יצירת Ansible inventory לפי כתובת ה-IP של השרת.
   - הרצת Ansible playbook.
   - בדיקת זמינות האתר באמצעות curl.

## ולידציה

לאחר סיום ה-Pipeline יש לוודא:

- Jenkins job הסתיים בסטטוס Success.
- Terraform output מציג כתובת IP וכתובת URL.
- פתיחת ה-URL בדפדפן מציגה את האתר.
- פקודת curl מחזירה HTTP 200.

## פרטי גישה להגשה

יש לצרף למרצה:

- קישור ל-GitHub repository.
- קישור ל-Jenkins.
- שם משתמש Jenkins עם הרשאת הרצת Job.
- קישור לאתר שהוקם.
- צילום מסך או פלט של Pipeline מוצלח.

## הערות אבטחה

- אין להעלות מפתחות פרטיים או קבצי `*.tfvars` ל-GitHub.
- יש לפתוח פורט 22 רק לכתובת IP נדרשת כאשר אפשר.
- בסיום הבדיקה מומלץ להריץ `terraform destroy`.
