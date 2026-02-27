"""
Technology Model for Flask Backend
"""
from datetime import datetime
from typing import Optional, Dict, Any


class Technology:
    """Technology model representing a technology entity"""
    
    def __init__(
        self,
        id: Optional[int] = None,
        name: str = "",
        description: str = "",
        category: str = "",
        version: Optional[str] = None,
        documentation_url: Optional[str] = None,
        is_active: bool = True,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None
    ):
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.version = version
        self.documentation_url = documentation_url
        self.is_active = is_active
        self.created_at = created_at or datetime.now()
        self.updated_at = updated_at
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert Technology object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'version': self.version,
            'documentation_url': self.documentation_url,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'Technology':
        """Create Technology object from dictionary"""
        return cls(
            id=data.get('id'),
            name=data.get('name', ''),
            description=data.get('description', ''),
            category=data.get('category', ''),
            version=data.get('version'),
            documentation_url=data.get('documentation_url'),
            is_active=data.get('is_active', True),
            created_at=datetime.fromisoformat(data['created_at']) if data.get('created_at') else None,
            updated_at=datetime.fromisoformat(data['updated_at']) if data.get('updated_at') else None,
        )
    
    def __repr__(self) -> str:
        return f"Technology(id={self.id}, name='{self.name}', category='{self.category}', version='{self.version}')"







