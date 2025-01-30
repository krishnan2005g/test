from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from typing import Dict

app = FastAPI()

# Dictionary to store active connections
active_connections: Dict[str, WebSocket] = {}

@app.websocket("/ws/{username}")
async def websocket_endpoint(websocket: WebSocket, username: str):
    await websocket.accept()
    active_connections[username] = websocket
    try:
        while True:
            data = await websocket.receive_text()
            recipient, message = data.split("|", 1)  # Expecting "recipient|message" format
            if recipient in active_connections:
                await active_connections[recipient].send_text(f"{username}: {message}")
                await websocket.send_text(f"Message sent to {recipient}")  # Acknowledge sender
            else:
                await websocket.send_text(f"User {recipient} not found")  # Error handling
    except WebSocketDisconnect:
        del active_connections[username]  # Remove disconnected user
