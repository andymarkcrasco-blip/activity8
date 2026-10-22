"""Pydantic request/response models for the Activity 10 REST API."""
from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field


# ------------------------------------------------------------------ auth
class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=60)
    password: str = Field(min_length=4, max_length=120)
    full_name: str = Field(min_length=2, max_length=120)
    email: Optional[str] = None
    role: str = Field(default="client")


class LoginRequest(BaseModel):
    username: str
    password: str


class UserOut(BaseModel):
    user_id: int
    username: str
    full_name: str
    email: Optional[str] = None
    role: str


class LoginResponse(BaseModel):
    ok: bool
    message: str
    token: Optional[str] = None
    user: Optional[UserOut] = None


# --------------------------------------------------------------- reports
class ReportIn(BaseModel):
    title: str = Field(min_length=5, max_length=150)
    category: str
    location: str = Field(min_length=2, max_length=100)
    description: str = Field(min_length=10)
    contact: Optional[str] = None


class ReportOut(BaseModel):
    report_id: int
    reference: str
    title: str
    category: str
    location: str
    description: str
    contact: Optional[str] = None
    status: str
    created_at: datetime


class ReportListResponse(BaseModel):
    ok: bool
    count: int
    reports: List[ReportOut]


class ReportCreateResponse(BaseModel):
    ok: bool
    message: str
    report: Optional[ReportOut] = None
