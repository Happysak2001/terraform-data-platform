# ─────────────────────────────────────────
# S3 RAW DATA BUCKET — the inbox tray
# Raw files (CSV, JSON, Parquet) land here first
# When a file arrives, it triggers Lambda automatically
# ─────────────────────────────────────────

resource "aws_s3_bucket" "raw_data" {
  bucket = "${var.project_name}-raw-data-2026"

  tags = {
    Name = "${var.project_name}-raw-data"
  }
}

# Block all public access — raw data is private
resource "aws_s3_bucket_public_access_block" "raw_data" {
  bucket = aws_s3_bucket.raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────
# CLOUDWATCH LOG GROUP — the diary
# Every Lambda run writes here
# You can see exactly what happened, when, and if it failed
# ─────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.project_name}-ingestion"
  retention_in_days = 14   # keep logs for 14 days then auto-delete
}

# ─────────────────────────────────────────
# LAMBDA FUNCTION — the intern who wakes up automatically
# Triggered every time a file lands in the S3 raw bucket
# Reads the event, logs the file details to CloudWatch
# ─────────────────────────────────────────

# First: zip the Python file — Lambda needs code as a zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

resource "aws_lambda_function" "ingestion" {
  function_name = "${var.project_name}-ingestion"
  role          = var.lambda_role_arn        # the badge from Phase 5
  handler       = "handler.handler"          # filename.functionname
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Environment variables — like config the Lambda can read at runtime
  environment {
    variables = {
      PROJECT_NAME = var.project_name
      LOG_LEVEL    = "INFO"
    }
  }

  # Make sure the log group exists before Lambda tries to write to it
  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}

# ─────────────────────────────────────────
# S3 TRIGGER — the wire connecting S3 to Lambda
# Tells S3: "when a file arrives, call this Lambda"
# ─────────────────────────────────────────

# Step 1: Give S3 permission to invoke Lambda
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data.arn
}

# Step 2: Tell the S3 bucket to fire an event when any file is uploaded
resource "aws_s3_bucket_notification" "raw_data_trigger" {
  bucket = aws_s3_bucket.raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ingestion.arn
    events              = ["s3:ObjectCreated:*"]   # trigger on ANY file upload
  }

  depends_on = [aws_lambda_permission.s3_trigger]
}
