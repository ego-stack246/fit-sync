from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.models.models import Base

engine = create_async_engine(settings.async_database_url, echo=False)
async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def init_db():
    """Initializes tables asynchronously on startup."""
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
    except Exception as e:
        print(f"Database initialization notice: {e}")

async def get_db():
    """Dependency for obtaining an asynchronous database session."""
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()
