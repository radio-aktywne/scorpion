import argparse
import json
import logging
import os
import sys
import time
from dataclasses import asdict, dataclass, replace
from http import HTTPStatus
from http.client import HTTPConnection, HTTPResponse, HTTPSConnection
from pathlib import Path
from types import TracebackType
from typing import Any, Literal, Self
from urllib.parse import urlparse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("configure")


@dataclass(frozen=True, kw_only=True)
class BaseClientData:
    """Base data of a client."""

    access_token_strategy: Literal["jwt", "opaque"] | None = None
    allowed_cors_origins: list[str] | None = None
    audience: list[str] | None = None
    authorization_code_grant_access_token_lifespan: str | None = None
    authorization_code_grant_id_token_lifespan: str | None = None
    authorization_code_grant_refresh_token_lifespan: str | None = None
    backchannel_logout_session_required: bool | None = None
    backchannel_logout_uri: str | None = None
    client_credentials_grant_access_token_lifespan: str | None = None
    client_name: str | None = None
    client_uri: str | None = None
    contacts: list[str] | None = None
    frontchannel_logout_session_required: bool | None = None
    frontchannel_logout_uri: str | None = None
    grant_types: list[str] | None = None
    implicit_grant_access_token_lifespan: str | None = None
    implicit_grant_id_token_lifespan: str | None = None
    jwks: dict | None = None
    jwks_uri: str | None = None
    jwt_bearer_grant_access_token_lifespan: str | None = None
    logo_uri: str | None = None
    metadata: dict | None = None
    owner: str | None = None
    policy_uri: str | None = None
    post_logout_redirect_uris: list[str] | None = None
    redirect_uris: list[str] | None = None
    refresh_token_grant_access_token_lifespan: str | None = None
    refresh_token_grant_id_token_lifespan: str | None = None
    refresh_token_grant_refresh_token_lifespan: str | None = None
    registration_access_token: str | None = None
    registration_client_uri: str | None = None
    request_object_signing_alg: str | None = None
    request_uris: list[str] | None = None
    response_types: list[str] | None = None
    scope: str | None = None
    sector_identifier_uri: str | None = None
    skip_consent: bool | None = None
    skip_logout_consent: bool | None = None
    subject_type: Literal["pairwise", "public"] | None = None
    token_endpoint_auth_method: (
        Literal["client_secret_basic", "client_secret_post", "none", "private_key_jwt"]
        | None
    ) = None
    token_endpoint_auth_signing_alg: str | None = None
    tos_uri: str | None = None
    userinfo_signed_response_alg: str | None = None

    def serialize(self) -> dict[str, Any]:
        """Serialize to a dictionary."""
        return {key: value for key, value in asdict(self).items() if value is not None}

    @classmethod
    def deserialize(cls, data: dict[str, Any]) -> Self:
        """Deserialize from a dictionary."""
        return cls(**data)


@dataclass(frozen=True, kw_only=True)
class Client(BaseClientData):
    """Data of a client."""

    client_id: str
    client_secret_expires_at: int
    created_at: str
    updated_at: str


@dataclass(frozen=True, kw_only=True)
class ClientRequest(BaseClientData):
    """Data of a request to create or update a client."""

    client_id: str | None = None
    client_secret: str | None = None


@dataclass(frozen=True, kw_only=True)
class Arguments:
    """Command-line arguments."""

    config: Path


@dataclass(frozen=True, kw_only=True)
class Configuration:
    """Configuration data."""

    clients: dict[str, ClientRequest]


class ArgumentsParser:
    """A parser for command-line arguments."""

    def __init__(self) -> None:
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument(
            "config", help="Path to the configuration file.", type=Path
        )

    def parse(self) -> Arguments:
        """Parse arguments."""
        args = self.parser.parse_args()
        return Arguments(config=args.config)


class ConfigurationLoader:
    """A loader for configuration."""

    def __init__(self, config: Path) -> None:
        self.config = config

    def load(self) -> Configuration:
        """Load configuration."""
        with self.config.open() as file:
            data = json.load(file)

        return Configuration(
            clients={
                client_id: ClientRequest.deserialize(config)
                for client_id, config in data.get("clients", {}).items()
            },
        )


class HTTPError(Exception):
    """An HTTP error occurred."""

    def __init__(self, status: int, reason: str) -> None:
        super().__init__(f"HTTP Error {status}: {reason}")
        self.status = status
        self.reason = reason


class HTTPClient:
    """Client for making HTTP requests."""

    def __init__(self, url: str) -> None:
        parsed = urlparse(url)
        self.scheme = parsed.scheme
        self.host = parsed.netloc
        self.path = parsed.path.rstrip("/")
        self.connection = (
            HTTPSConnection(self.host)
            if self.scheme == "https"
            else HTTPConnection(self.host)
        )

    def request(
        self,
        method: str,
        path: str,
        body: str | None = None,
        headers: dict[str, str] | None = None,
    ) -> HTTPResponse:
        """Make a request."""
        self.connection.request(
            method, f"{self.path}{path}", body=body, headers=headers or {}
        )
        response = self.connection.getresponse()

        if response.status >= HTTPStatus.BAD_REQUEST:
            raise HTTPError(response.status, response.reason)

        return response

    def get(self, path: str) -> HTTPResponse:
        """Make a GET request."""
        return self.request("GET", path)

    def post(self, path: str, body: dict) -> HTTPResponse:
        """Make a POST request."""
        return self.request(
            "POST",
            path,
            body=json.dumps(body),
            headers={"Content-Type": "application/json"},
        )

    def put(self, path: str, body: dict) -> HTTPResponse:
        """Make a PUT request."""
        return self.request(
            "PUT",
            path,
            body=json.dumps(body),
            headers={"Content-Type": "application/json"},
        )

    def delete(self, path: str) -> HTTPResponse:
        """Make a DELETE request."""
        return self.request("DELETE", path)

    def close(self) -> None:
        """Close the connection."""
        self.connection.close()

    def __enter__(self) -> Self:
        return self

    def __exit__(
        self,
        exception_type: type[BaseException] | None,
        exception: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        return self.close()


class HydraClient:
    """A client for the Ory Hydra Admin API."""

    def __init__(self, url: str) -> None:
        self.url = url

    def ping(self) -> None:
        """Ping the service."""
        with HTTPClient(self.url) as http:
            http.get("/health/ready")

    def list_clients(self) -> list[Client]:
        """List all clients."""
        with HTTPClient(self.url) as http:
            response = http.get("/admin/clients")
            data = response.read()

        return [Client.deserialize(client) for client in json.loads(data)]

    def create_client(self, request: ClientRequest) -> None:
        """Create a client."""
        with HTTPClient(self.url) as http:
            http.post("/admin/clients", body=request.serialize())

    def update_client(self, client_id: str, request: ClientRequest) -> None:
        """Update a client."""
        with HTTPClient(self.url) as http:
            http.put(f"/admin/clients/{client_id}", body=request.serialize())


class HydraClientBuilder:
    """A builder for HydraClient."""

    def build(self) -> HydraClient:
        """Build the client."""
        host = os.getenv("SCORPION__SERVER__HOST", "localhost")
        port = os.getenv("SCORPION__SERVER__PORTS__ADMIN", "20001")
        url = f"http://{host}:{port}"

        return HydraClient(url)


class SynchronizationError(Exception):
    """An error occurred during synchronization."""

    def __init__(self) -> None:
        super().__init__("Failed to synchronize configuration.")


class ClientSynchronizer:
    """A synchronizer for Ory Hydra clients."""

    def __init__(self, hydra: HydraClient, configs: dict[str, ClientRequest]) -> None:
        self.hydra = hydra
        self.configs = configs

    def _list_clients(self) -> list[Client]:
        return self.hydra.list_clients()

    def _update_client(self, client_id: str) -> None:
        config = self.configs[client_id]
        request = replace(config, client_id=config.client_id or client_id)

        try:
            self.hydra.update_client(client_id, request)
        except (ConnectionError, HTTPError) as error:
            if isinstance(error, HTTPError) and error.status == HTTPStatus.NOT_FOUND:
                self._create_client(client_id)
                return

            logger.exception("Failed to update client %s.", client_id)
            raise SynchronizationError from error

    def _create_client(self, client_id: str) -> None:
        config = self.configs[client_id]
        request = replace(config, client_id=config.client_id or client_id)

        try:
            self.hydra.create_client(request)
        except (ConnectionError, HTTPError) as error:
            if isinstance(error, HTTPError) and error.status == HTTPStatus.CONFLICT:
                self._update_client(client_id)
                return

            logger.exception("Failed to create client %s.", client_id)
            raise SynchronizationError from error

    def synchronize(self) -> None:
        """Synchronize clients."""
        clients = self._list_clients()

        current = {client.client_id for client in clients}
        target = set(self.configs.keys())

        create = target - current
        update = current & target

        for client_id in update:
            logger.info("Updating client %s...", client_id)
            self._update_client(client_id)

        for client_id in create:
            logger.info("Creating client %s...", client_id)
            self._create_client(client_id)


class ConfigurationSynchronizer:
    """A synchronizer for Ory Hydra configuration."""

    def __init__(self, hydra: HydraClient, config: Configuration) -> None:
        self.hydra = hydra
        self.config = config

    def _wait_for_hydra(self) -> None:
        logger.info("Waiting for Ory Hydra to become ready...")

        for _ in range(10):
            try:
                self.hydra.ping()
            except (ConnectionError, HTTPError):
                logger.info("Ory Hydra is not ready. Retrying in 1 second...")
                time.sleep(1)
            else:
                logger.info("Ory Hydra is ready. Waiting additional 5 seconds...")
                time.sleep(5)
                return

        logger.error("Ory Hydra did not become ready.")
        raise SynchronizationError

    def synchronize(self) -> None:
        """Synchronize configuration."""
        logger.info("Synchronizing configuration...")

        self._wait_for_hydra()

        ClientSynchronizer(self.hydra, self.config.clients).synchronize()

        logger.info("Synchronization complete.")


def main() -> None:
    """Run main entry point."""
    arguments = ArgumentsParser().parse()
    config = ConfigurationLoader(arguments.config).load()
    hydra = HydraClientBuilder().build()

    synchronizer = ConfigurationSynchronizer(hydra, config)

    try:
        synchronizer.synchronize()
    except SynchronizationError:
        logger.exception("Failed to synchronize configuration.")
        sys.exit(1)


if __name__ == "__main__":
    main()
