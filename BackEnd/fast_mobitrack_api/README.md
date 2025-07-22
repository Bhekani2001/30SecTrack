# Live Location Tracker FastAPI Backend

## Setup Instructions

1. **Install dependencies**
   ```powershell
   pip install -r requirements.txt
   ```

2. **Run the API server**
   ```powershell
   uvicorn app:app --reload
   ```
   - The API will be available at `http://localhost:8000`

## Endpoints

- `POST /location` - Send location data
- `GET /locations` - Retrieve location history (supports pagination: `skip`, `limit`)
- `GET /locations/{unit_id}` - Get locations for a specific device (supports pagination)

## Data Format
```json
{
  "unit_id": "string",
  "latitude": 0.0,
  "longitude": 0.0,
  "timestamp": "2025-07-14T10:30:00Z"
}
```

## Testing
- Use tools like Postman or your Flutter app to test endpoints.
- Data is stored in `location.db` (SQLite).

## Notes
- CORS is enabled for mobile app requests.
- All endpoints return proper HTTP status codes and error messages.
- For production, restrict CORS origins and consider adding authentication.

---

For any issues, contact: calvin@finmon.co.za
