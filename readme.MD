Terraform AWS Workstation - Simple Guide
What Does This Do?
Creates a ready-to-use Kubernetes workstation on AWS with Docker, kubectl, k9s, and an EKS cluster.

In simple terms:-
1.Creates a virtual computer on AWS
2.Installs DevOps tools on it
3.Creates a Kubernetes cluster
You can SSH in and use it immediately



Prerequisites (Before Starting):-
1.Terraform installed: https://www.terraform.io/downloads
2.AWS Account with credentials (Access Key & Secret Key)
3.Git installed


Verify installations:-
bashterraform -version
aws --version
git --version


ALL COMMANDS IN ORDER

1. CLONE THE REPO

bashgit clone https://github.com/daws-88s/terraform-aws-workstation.git
cd terraform-aws-workstation

2. CONFIGURE AWS

bashaws configure

Enter:

AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name: us-east-1
Default output format: json

3. CREATE terraform.tfvars FILE

On Windows (PowerShell):

powershell@"
aws_access_key = "AKIAIOSFODNN7EXAMPLE"
aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
ssh_password   = "MyPassword123!"
"@ | Out-File terraform.tfvars -Encoding UTF8

On Linux/Mac:

bashcat > terraform.tfvars << EOF
aws_access_key = "AKIAIOSFODNN7EXAMPLE"
aws_secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
ssh_password   = "MyPassword123!"
EOF

4. INITIALIZE TERRAFORM

bashterraform init

5. REVIEW PLAN (OPTIONAL)

bashterraform plan

6. CREATE EVERYTHING

bashterraform apply

When asked: Type yes and press Enter

⏳ Wait 10-15 minutes for everything to be created.

After completion, you'll see:

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

7. GET YOUR EC2 IP ADDRESS

bashterraform state show aws_instance.workstation

Look for public_ip = "12.34.56.78" (your IP will be different)

8. SSH INTO THE MACHINE

bashssh ec2-user@12.34.56.78

When asked for password, enter: MyPassword123! (the password you set in step 3)

9. TEST KUBERNETES (After SSH)

bashkubectl get nodes
kubectl get pods -A
k9s

10. WHEN DONE, DELETE EVERYTHING

bashterraform destroy

When asked: Type yes and press Enter


Quick Copy-Paste Commands

bash# Step 1-2
git clone https://github.com/daws-88s/terraform-aws-workstation.git
cd terraform-aws-workstation
aws configure

# Step 3 (Create terraform.tfvars with your values)
# Edit the file with your AWS credentials and choose a password

# Step 4-6
terraform init
terraform apply
# Type: yes

# Step 7-8 (After 10-15 minutes)
terraform state show aws_instance.workstation
ssh ec2-user@YOUR_IP_HERE

# Step 9 (After SSH)
kubectl get nodes

# Step 10 (When done)
terraform destroy
# Type: yes


Important Values to Remember

WhatWhere It Comes FromWhere You Use ItAWS Access KeyAWS Console → IAMterraform.tfvarsAWS Secret KeyAWS Console → IAMterraform.tfvarsSSH PasswordYou create itterraform.tfvars & SSH loginEC2 Public IPShown after terraform applySSH connection: ssh ec2-user@IP


Troubleshooting

ProblemSolutionterraform: command not foundDownload and add Terraform to PATHaws: command not foundDownload AWS CLIAccess Denied errorCheck AWS credentials in terraform.tfvarsSSH connection refusedWait 5 more minutes for instance to fully bootCan't remember passwordCheck terraform.tfvars file you createdEKS cluster not createdSSH in and run: aws eks list-clustersWant to see logsSSH in and run: cat /var/log/cloud-init-output.log


What Gets Created (Cost Estimate)

ResourceCostEC2 Instance (t3.micro)~$0.01/hourEKS Cluster~$0.10/hourEBS Storage (50GB)~$2-3/monthTotal~$0.11/hour (~$80/month if left running)

💡 TIP: Always run terraform destroy when not using it to avoid charges!


Common Commands Once You're In

bash# After SSH into the machine

# View Kubernetes nodes
kubectl get nodes

# View all pods
kubectl get pods -A

# Open Kubernetes dashboard
k9s

# View EKS cluster info
eksctl get cluster

# Describe cluster
aws eks describe-cluster --name roboshop --region us-east-1

# Switch Kubernetes namespaces
kubens

# Run Docker containers
docker run -it ubuntu bash


Need Help?


Check the .terraform folder exists (means terraform init worked)
Check terraform.tfvars has correct credentials
Check EC2 instance is in running state in AWS Console
Wait longer (EKS takes 10-15 minutes)
Check security group allows SSH (should be created automatically)



Last Updated: 2026
Project: terraform-aws-workstation