terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# Example of a booking
#   "booking_id": "2023-09-20T10:30_ConferenceRoom"
#   "room_name": "Conference Room"
#   "start_time": "2023-09-20T10:30:00"
#   "end_time": "2023-09-20T11:30:00"
#   "booked_by": "john@example.com"
resource "aws_dynamodb_table" "bookings" {
  name         = "bookings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "booking_id"

  attribute {
    name = "booking_id"
    type = "S"
  }

  # Email of the person who booked the room
  attribute {
    name = "booked_by"
    type = "S"
  }

  # Global secondary index for bookings by user
  global_secondary_index {
    name            = "BookedByIndex"
    hash_key        = "booked_by"
    projection_type = "ALL"
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "booking_api" {
  name = "booking-api"
}

# Archive file for lambda function
data "archive_file" "lambda_book_room" {
  type = "zip"

  source_file = "${path.module}/lambda/book-room.py"
  output_path = "book_room.zip"
}

# IAM role for lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-booking-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "lambda-dynamodb-booking-policy"
  description = "Permissions for Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.bookings.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

# Lambda function
resource "aws_lambda_function" "book_room" {
  filename      = "book_room.zip"
  function_name = "book_room"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.lambda_book_room.output_base64sha256

  handler = "book_room.lambda_handler"
  runtime = "python3.8"
}
