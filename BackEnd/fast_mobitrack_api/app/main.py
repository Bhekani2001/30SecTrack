from fastapi import FastAPI, APIRouter, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from app.database.database import Base, engine
from app.routes.auth_router import router as auth_router
from app.routes.location_router import router as location_router
from typing import Dict, List

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(location_router)

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, unit_id: str, websocket: WebSocket):
        await websocket.accept()
        if unit_id not in self.active_connections:
            self.active_connections[unit_id] = []
        self.active_connections[unit_id].append(websocket)

    def disconnect(self, unit_id: str, websocket: WebSocket):
        self.active_connections[unit_id].remove(websocket)
        if not self.active_connections[unit_id]:
            del self.active_connections[unit_id]

    async def broadcast(self, unit_id: str, message: dict):
        for connection in self.active_connections.get(unit_id, []):
            await connection.send_json(message)

manager = ConnectionManager()

@router.websocket("/ws/location/{unit_id}")
async def websocket_endpoint(websocket: WebSocket, unit_id: str):
    await manager.connect(unit_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            await manager.broadcast(unit_id, data)
    except WebSocketDisconnect:
        manager.disconnect(unit_id, websocket)
    except Exception:
        manager.disconnect(unit_id, websocket)