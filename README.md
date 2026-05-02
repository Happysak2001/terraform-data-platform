# Terraform Data Platform Infrastructure on AWS

A complete cloud data platform built with Terraform. Deploys a production-ready
AWS infrastructure including networking, compute, database, and a data engineering
layer — all managed as code.

---

## What This Builds

```
Internet
    │
    ▼
S3 Raw Data Bucket (data inbox)
    │ triggers automatically
    ▼
Lambda Function (ingestion trigger)
    │ logs to
    ▼
CloudWatch (monitoring & logs)

Inside VPC:
├── Public Subnet
│   └── EC2 Server (data processing)
└── Private Subnet
    └── RDS MySQL (metadata store)
```

---

## Infrastructure Components

| Phase | Component | Purpose |
|---|---|---|
| 1 | S3 + Native S3 Lockfile | Terraform remote state & locking |
| 2 | VPC, Subnets, IGW, Route Tables | Network foundation |
| 3 | Security Groups, EC2 | Processing server & firewall rules |
| 4 | RDS MySQL | Managed database in private subnet |
| 5 | IAM Roles & Policies | Service permissions & badges |
| 6 | S3 Raw Bucket, Lambda, CloudWatch | Data engineering pipeline |

---

## Project Structure

```
terraform-data-platform/
├── bootstrap/               # Run once — creates S3 backend + DynamoDB lock
│   └── main.tf
├── modules/
│   ├── networking/          # VPC, subnets, internet gateway, route tables
│   ├── compute/             # EC2 instance, security groups
│   ├── database/            # RDS MySQL, subnet group
│   ├── iam/                 # IAM roles and policies
│   └── data_layer/          # S3 raw bucket, Lambda, CloudWatch
│       └── lambda/
│           └── handler.py   # Python ingestion trigger
├── main.tf                  # Root module — connects all modules
├── variables.tf             # Variable definitions
├── outputs.tf               # Output values after apply
├── backend.tf               # S3 remote backend configuration
└── terraform.tfvars.example # Safe example — copy to terraform.tfvars
```

---

## How to Use

### Prerequisites
- Terraform v1.6+
- AWS CLI configured (`aws configure`)
- AWS account with IAM permissions

### Step 1 — Bootstrap (run once)
```bash
cd bootstrap
terraform init
terraform apply
```
This creates the S3 bucket and DynamoDB table for remote state.

### Step 2 — Configure your values
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `terraform.tfvars` with your real values:
```
aws_region    = "us-east-1"
project_name  = "data-platform"
environment   = "dev"
key_pair_name = "your-key-pair-name"
db_username   = "admin"
db_password   = "your-secure-password"
```

### Step 3 — Deploy the platform
```bash
cd ..
terraform init
terraform plan
terraform apply
```

### Step 4 — Test the pipeline
```bash
# Upload a file to trigger Lambda
aws s3 cp test.csv s3://data-platform-raw-data-2026/raw/test.csv

# Watch Lambda logs in real time
aws logs tail /aws/lambda/data-platform-ingestion --follow
```

### Step 5 — Destroy when done
```bash
terraform destroy
cd bootstrap
terraform destroy
```

---

## Outputs After Apply

```
ec2_public_ip   = "x.x.x.x"         # SSH into your server
rds_endpoint    = "xxx.rds.amazonaws.com:3306"  # Database endpoint
raw_data_bucket = "data-platform-raw-data-2026" # Drop files here
lambda_function = "data-platform-ingestion"      # Auto trigger
cloudwatch_logs = "/aws/lambda/data-platform-ingestion"
```

---

## Data Flow

```
1. Raw file dropped into S3 bucket
2. S3 triggers Lambda automatically
3. Lambda logs file details to CloudWatch
4. Data engineer SSHes into EC2
5. Python script processes the file
6. Results saved to RDS MySQL
```

---

## Security

- Database in private subnet — not reachable from internet
- EC2 security group — SSH only
- RDS security group — MySQL from EC2 only
- IAM least privilege — each service has minimum permissions
- S3 state bucket — encrypted, versioned, private, with native S3 lockfile
- Secrets managed via terraform.tfvars — never committed to Git

---

## Tech Stack

- **Terraform** v1.15
- **AWS** — VPC, EC2, RDS, S3, Lambda, IAM, CloudWatch, DynamoDB
- **Python** 3.12 — Lambda function
- **MySQL** 8.0 — RDS database
