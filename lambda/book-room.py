import json
import boto3

dynamodb = boto3.resource('dynamodb')
bookings_table = dynamodb.Table('bookings')

def lambda_handler(event, context):
    #Parse JSON from API Gateway
    booking_data = json.loads(event['body'])
    
    #Generate booking ID
    booking_id = f"{booking_data['start_time']}_{booking_data['room_name']}"
    
    try:
        #Save booking to DynamoDB
        bookings_table.put_item(
            Item={
                'booking_id': booking_id,
                'room_name': booking_data['room_name'],
                'start_time': booking_data['start_time'],
                'end_time': booking_data['end_time'],
                'booked_by': booking_data['booked_by']
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Booking successful!')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error booking room: {str(e)}')
        }
