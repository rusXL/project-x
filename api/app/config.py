from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str
    allowed_origins: list[str] = ["http://localhost:3000"]
    app_name: str = "AGAMA"
    max_items: int = 1_000_000

    model_config = SettingsConfigDict(env_file=".env")


settings = Settings()
