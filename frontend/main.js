const bookRoom = async () => {
    const form = document.getElementById('bookingForm');
    const API_URL = 'https://TBD';

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const bookingData = {
            room_name: document.getElementById('roomName').value,
            start_time: document.getElementById('startTime').value,
            end_time: document.getElementById('endTime').value,
            booked_by: document.getElementById('email').value
        };

        try {
            const response = await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(bookingData)
            });
            alert('Booking successful!');
        } catch (error) {
            alert('Error: ' + error);
        }
    });
 }
    