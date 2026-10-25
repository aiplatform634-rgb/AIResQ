from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class EmergencyRequest(BaseModel):
    name: str
    emergency_type: str
    description: str
    latitude: float
    longitude: float


@app.get("/")
def home():
    return {"message": "ResQAI Backend is running"}


@app.post("/emergency")
def create_emergency(request: EmergencyRequest):
    return {
        "message": "Emergency request received",
        "request": request
    }