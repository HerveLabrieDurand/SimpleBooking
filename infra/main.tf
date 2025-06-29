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