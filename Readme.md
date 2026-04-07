### 🚀 RankHex Nexus 3 Infrastructure (AWS + Terraform)
This repository contains the Production-Grade Infrastructure as Code (IaC) for Sonatype Nexus 3. It utilizes a highly secure, 3-tier architecture with automated SSL (ACM), DNS management (Route53), and self-healing compute (ASG).

#### 🏗️ Architecture Overview
The infrastructure is split into two distinct layers to ensure stability and modularity:

1. Infrastructure Layer (infra): VPC, Subnets, NAT Gateways, EFS, S3, Route53, ACM, and Load Balancers.

2. Application Layer (app): IAM Roles, Auto Scaling Groups, Launch Templates, and Cloud-init automation scripts.

#### 🛡️ Key Security Features:
- SSL/TLS: Automatic redirection from Port 80 to 443.

- Security Group Chaining: The EC2 instance only accepts traffic from the Load Balancer.

- Least Privilege: IAM roles are scoped strictly to specific S3 buckets and EFS IDs.

- Data Persistence: Configuration is stored in EFS, while artifacts are stored in S3.

#### 🛠️ Prerequisites
- Terraform (v1.5.0+) installed on your Mac M4 Air.

- AWS CLI configured with Administrator access.

- A Registered Domain: (e.g., rankhex.in).

- S3 & DynamoDB for State: You must create the state bucket and lock table (see bootstrap folder).

#### 🚦 Deployment Sequence (Critical)
Follow these steps in order. **Do not run the App layer until the Infra layer is finished.**

_**Step 1: Infrastructure (The Foundation)**_
1. Navigate to `stages/prelive/infra`.

2. Update terraform.tfvars with your actual AWS Account ID.

3. Run the following:

```Bash
terraform init
terraform apply
```
4. Note: Terraform will pause at the "*Certificate Validation*" step.

5. Action Required: Check the terminal output for `route53_nameservers`. Go to your domain registrar (Namecheap/GoDaddy) and update your domain to use these 4 AWS Name Servers.

Once DNS propagates, Terraform will automatically finish the apply.

_**Step 2: Application (The Server)**_
1. Navigate to `stages/prelive/app`.

2. Run the following:

```Bash
terraform init
terraform apply
```

3. Wait ~7–10 minutes for the Nexus Java process to boot and mount the EFS drive.

### 📁 Project Structure
```Plaintext
.
├── Readme.md
├── backend
│   ├── main.tf
│   └── variables.tf
├── modules
│   ├── app
│   │   ├── asg.tf
│   │   ├── cloud_init.tf
│   │   ├── iam.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── infra
│       ├── dns_ssl.tf
│       ├── load_balancers.tf
│       ├── outputs.tf
│       ├── route53.tf
│       ├── security_groups.tf
│       ├── storage.tf
│       ├── variables.tf
│       └── vpc.tf
├── scripts
│   ├── amazon-time-sync.sh
│   ├── cloudwatch-agent.sh
│   ├── install-nexus.sh
│   ├── iptables.sh
│   ├── setup-efs.sh
│   └── templates
│       └── cw-agent-config.json.tftpl
└── stages
    └── prelive
        ├── app
        │   ├── data.tf
        │   ├── main.tf
        │   ├── outputs.tf
        │   ├── provider.tf
        │   ├── terraform.tfvars
        │   └── variables.tf
        └── infra
            ├── main.tf
            ├── outputs.tf
            ├── provider.tf
            ├── terraform.tfvars
            └── variables.tf

```
### 🔗 Accessing the Portal
Once the deployment is finished, you can access your services at:

- Nexus UI: https://prelive.rankhex.in/nexus/

- Docker Registry: https://prelive.rankhex.in:5000 (Use docker login)

### 🛡️ Maintenance & Scaling
- Scaling: To change the instance size, update `instance_type` in `stages/prelive/app/terraform.tfvars` and run `terraform apply`.

- Updates: To update the Nexus version or configuration, modify the scripts in the `scripts/` folder and trigger an `instance_refresh` via Terraform.

- Remote State: All state files are stored in S3. If you move to a new machine, simply run `terraform init` to pull the latest state from the cloud.

