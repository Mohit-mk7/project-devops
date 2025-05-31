# project-devops
project-devops


🔧 1. Infrastructure Provisioning with Terraform
Designed a modular Terraform setup with the following structure:
terraform/
├── modules/
│   ├── alb/
│   ├── ec2/
│   ├── ecr/
│   └── vpc/
├── backend.tf
├── main.tf
├── variables.tf
├── terraform.tfvars




Disclaimer: if we try to create a bucket in the same module then we will get an error message.
Terraform cannot create an S3 bucket while simultaneously trying to use that same bucket as a backend for its state. 
Do Not Try to Create the Bucket From Inside the Same Terraform Project Using That Backend

Key Components:
VPC: Created a VPC with public and private subnets.


EC2 Instances:


Jump Server (public): Hosts Jenkins and serves as a bastion.


Private Server: Hosts the application container.


NAT Gateway: Enables the private instance to access the internet.


ALB: Application Load Balancer targets the private server (on port 3005).


ECR: A Docker image repository created and managed via Terraform.


Terraform Backend:


Remote backend configured with an S3 bucket to store the terraform.tfstate.


Enabled state locking with a DynamoDB table or S3 versioning.










Module explanation

—----------------------------------------------------------------------------

Layer
Who Reads It?
What’s its Role?
terraform.tfvars
Terraform root engine
Supplies values for root-level variable blocks
root/variables.tf
Terraform root engine
Declares root variables (e.g., var.key_name)
root/main.tf
You (manually wiring modules)
Passes var.key_name to module inputs
module/variables.tf
Module logic
Declares expected inputs inside the module
module/main.tf
Module logic
Uses var.key_name in resource blocks


—------------------------------------------------------------------------------
You provide a value (ec2_key_from_user = "my-ec2-key") in terraform.tfvars.


Terraform assigns it to var.ec2_key_from_user from root's variables.tf.


You wire it into a module using module "ec2" { key_name = var.ec2_key_from_user }.


Module sees that it has a variable "key_for_ec2_mod" and accepts the value.
Here the wiring happens.
You’re saying:
"Hey ec2_instance_module, here's a variable called key_for_ec2_mod, and its value comes from my var.ec2_key_from_user."


Module uses var.key_for_ec2_mod in resources like EC2.
—------------------------------------------------------------------------------------------



terraform.tfvars
       ↓
root/variables.tf   → declares variables
       ↓
root/main.tf        → wires values into modules
       ↓
module/variables.tf → receives parameters
       ↓
module/main.tf      → uses the parameters

—-------------------------------------------------------------------------


2. Configuration Management with Ansible
Ansible was used to automate the provisioning and configuration of the two EC2 instances:
✨ Tasks performed:
Jump Server (Public):


Installed Docker


Installed Jenkins


Installed AWS CLI


Configured Jenkins to run with Docker privileges


Private Server:


Installed Docker


Installed AWS CLI


Added ubuntu user to Docker group


Both servers were configured without any manual SSH logins, maintaining true infrastructure-as-code and configuration-as-code principles.
Ansible-playbook -i inventory.ini playbook.yml

3. CI/CD Pipeline with Jenkins and GitHub
🏗️ Jenkins Setup:
Jenkins installed and managed via Ansible on the jump server.


Plugins installed:


GitHub integration plugin


Docker plugin


ECR plugin


AWS CLI plugin (or system AWS CLI manually configured)


⚙️ Jenkins Pipeline Configuration:
Created a new Pipeline project.


Used "Pipeline script from SCM" method.


Connected to a GitHub repository (configured with webhook for auto-build).


🔐 Credentials Used:
GitHub credentials for pulling code


AWS Access Key and Secret Access Key (stored securely in Jenkins Credentials Manager)


🔁 Workflow:
Code is pushed to GitHub.


Webhook triggers Jenkins job.


Jenkins builds Docker image.


Image is pushed to ECR.


Jenkins deploys the container on the private EC2 instance.



🌐 Networking and Security
ALB listens on port 3005 and forwards requests to the private EC2.


Health checks and listener rules configured via Terraform.


Proper IAM permissions and roles were assigned.


EC2 instances were launched in us-east-1 region, complying with SCP restrictions.



🧩 Highlights & Best Practices Followed
🧱 Modular Terraform codebase for reusability and separation of concerns


🗃️ State Management using S3 backend with locking


🛡️ Secure Automation: No need to manually SSH into any instance


📦 CI/CD Pipeline that builds, pushes, and deploys Dockerized applications


🧰 End-to-end automation with zero manual steps once deployed
