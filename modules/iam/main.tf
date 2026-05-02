# ─────────────────────────────────────────
# IAM ROLE FOR EC2
# This is the badge we give to the EC2 server
# It allows EC2 to talk to S3 (read/write data files)
# Without this badge, EC2 cannot touch S3 at all
# ─────────────────────────────────────────

# Step 1: Create the role (the badge itself)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # This says: "EC2 service is allowed to wear this badge"
  # Only EC2 can assume this role — not Lambda, not a human
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Step 2: Define what the badge allows
# This policy says: EC2 can read and write to S3
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",      # read a file from S3
          "s3:PutObject",      # write a file to S3
          "s3:ListBucket",     # list files in S3 bucket
          "s3:DeleteObject"    # delete a file from S3
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",    # any bucket with our project name
          "arn:aws:s3:::${var.project_name}-*/*"   # any file inside those buckets
        ]
      }
    ]
  })
}

# Step 3: Attach the badge to EC2
# An instance profile is how you attach an IAM role to an EC2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ─────────────────────────────────────────
# IAM ROLE FOR LAMBDA
# This is the badge we give to the Lambda function
# Lambda needs permission to:
# - Read from S3 (to process incoming files)
# - Write logs to CloudWatch (so we can see what happened)
# ─────────────────────────────────────────

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  # Only Lambda service can wear this badge
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Allow Lambda to write logs to CloudWatch
# Without this, Lambda runs silently — you can't see what happened
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow Lambda to read files from S3
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name = "${var.project_name}-lambda-s3-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",    # read the file that just landed
          "s3:ListBucket"    # list files in the bucket
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*",
          "arn:aws:s3:::${var.project_name}-*/*"
        ]
      }
    ]
  })
}
