import argparse
import json
import logging
import os
import sys
import time
from dataclasses import dataclass
from http import HTTPStatus
from http.client import HTTPConnection, HTTPResponse, HTTPSConnection
from pathlib import Path
from typing import Self
from urllib.parse import urlparse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("configure")


@dataclass
class Arguments:
    """Command-line arguments."""

    config: Path


@dataclass
class TokenEndpointConfig:
    """Configuration for a token endpoint."""

    auth: str | None

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        """Deserialize from a dictionary."""

        return cls(
            auth=data.get("auth"),
        )


@dataclass
class EndpointsConfig:
    """Configuration for scorpion endpoints."""

    token: TokenEndpointConfig | None

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        """Deserialize from a dictionary."""

        return cls(
            token=(
                TokenEndpointConfig.deserialize(data["token"])
                if "token" in data
                else None
            ),
        )


@dataclass
class FrontChannelLogoutConfig:
    """Configuration for front-channel logout."""

    path: str
    session: bool | None

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        """Deserialize from a dictionary."""

        return cls(
            path=data["path"],
            session=data.get("session"),
        )


@dataclass
class LogoutConfig:
    """Configuration for logout."""

    frontchannel: FrontChannelLogoutConfig | None
    redirects: list[str] | None

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        """Deserialize from a dictionary."""

        return cls(
            frontchannel=(
                FrontChannelLogoutConfig.deserialize(data["frontchannel"])
                if "frontchannel" in data
                else None
            ),
            redirects=data.get("redirects"),
        )


@dataclass
class ClientConfig:
    """Configuration for a scorpion client."""

    callback: str
    endpoints: EndpointsConfig | None
    grants: list[str] | None
    logout: LogoutConfig | None
    scopes: list[str] | None
    secret: str
    url: str

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        """Deserialize from a dictionary."""

        return cls(
            callback=data["callback"],
            endpoints=(
                EndpointsConfig.deserialize(data["endpoints"])
                if "endpoints" in data
                else None
            ),
            grants=data.get("grants"),
            logout=(
                LogoutConfig.deserialize(data["logout"]) if "logout" in data else None
            ),
            scopes=data.get("scopes"),
            secret=data["secret"],
            url=data["url"],
        )


@dataclass
class Configuration:
    """Configuration data."""

    clients: dict[str, ClientConfig]


@dataclass
class Client:
    """An Ory Hydra client."""

    client_id: str

    @classmethod
    def deserialize(cls, data: dict) -> Self:
        return cls(
            client_id=data["client_id"],
        )


@dataclass
class CreateClientRequest:
    """Request to create an Ory Hydra client."""

    client_id: str | None
    client_name: str | None
    client_secret: str | None
    frontchannel_logout_session_required: bool | None
    frontchannel_logout_uri: str | None
    grant_types: list[str] | None
    post_logout_redirect_uris: list[str] | None
    redirect_uris: list[str] | None
    scope: str | None
    token_endpoint_auth_method: str | None

    def serialize(self) -> dict:
        """Serialize to a dictionary."""

        data = {}

        if self.client_id is not None:
            data["client_id"] = self.client_id

        if self.client_name is not None:
            data["client_name"] = self.client_name

        if self.client_secret is not None:
            data["client_secret"] = self.client_secret

        if self.frontchannel_logout_session_required is not None:
            data["frontchannel_logout_session_required"] = (
                self.frontchannel_logout_session_required
            )

        if self.frontchannel_logout_uri is not None:
            data["frontchannel_logout_uri"] = self.frontchannel_logout_uri

        if self.grant_types is not None:
            data["grant_types"] = self.grant_types

        if self.post_logout_redirect_uris is not None:
            data["post_logout_redirect_uris"] = self.post_logout_redirect_uris

        if self.redirect_uris is not None:
            data["redirect_uris"] = self.redirect_uris

        if self.scope is not None:
            data["scope"] = self.scope

        if self.token_endpoint_auth_method is not None:
            data["token_endpoint_auth_method"] = self.token_endpoint_auth_method

        return data


@dataclass
class UpdateClientRequest:
    """Request to update an Ory Hydra client."""

    client_id: str | None
    client_name: str | None
    client_secret: str | None
    frontchannel_logout_session_required: bool | None
    frontchannel_logout_uri: str | None
    grant_types: list[str] | None
    post_logout_redirect_uris: list[str] | None
    redirect_uris: list[str] | None
    scope: str | None
    token_endpoint_auth_method: str | None

    def serialize(self) -> dict:
        """Serialize to a dictionary."""

        data = {}

        if self.client_id is not None:
            data["client_id"] = self.client_id

        if self.client_name is not None:
            data["client_name"] = self.client_name

        if self.client_secret is not None:
            data["client_secret"] = self.client_secret

        if self.frontchannel_logout_session_required is not None:
            data["frontchannel_logout_session_required"] = (
                self.frontchannel_logout_session_required
            )

        if self.frontchannel_logout_uri is not None:
            data["frontchannel_logout_uri"] = self.frontchannel_logout_uri

        if self.grant_types is not None:
            data["grant_types"] = self.grant_types

        if self.post_logout_redirect_uris is not None:
            data["post_logout_redirect_uris"] = self.post_logout_redirect_uris

        if self.redirect_uris is not None:
            data["redirect_uris"] = self.redirect_uris

        if self.scope is not None:
            data["scope"] = self.scope

        if self.token_endpoint_auth_method is not None:
            data["token_endpoint_auth_method"] = self.token_endpoint_auth_method

        return data


class CreateClientRequestBuilder:
    """A builder for CreateClientRequest."""

    def build(self, id: str, config: ClientConfig) -> CreateClientRequest:
        """Build the request."""

        return CreateClientRequest(
            client_id=id,
            client_name=id,
            client_secret=config.secret,
            frontchannel_logout_session_required=(
                config.logout.frontchannel.session
                if config.logout and config.logout.frontchannel
                else None
            ),
            frontchannel_logout_uri=(
                config.url + config.logout.frontchannel.path
                if config.logout and config.logout.frontchannel
                else None
            ),
            grant_types=config.grants,
            post_logout_redirect_uris=(
                [config.url + path for path in config.logout.redirects]
                if config.logout
                else None
            ),
            redirect_uris=[config.url + config.callback],
            scope=" ".join(config.scopes) if config.scopes else None,
            token_endpoint_auth_method=(
                config.endpoints.token.auth
                if config.endpoints and config.endpoints.token
                else None
            ),
        )


class UpdateClientRequestBuilder:
    """A builder for UpdateClientRequest."""

    def build(self, id: str, config: ClientConfig) -> UpdateClientRequest:
        """Build the request."""

        return UpdateClientRequest(
            client_id=id,
            client_name=id,
            client_secret=config.secret,
            frontchannel_logout_session_required=(
                config.logout.frontchannel.session
                if config.logout and config.logout.frontchannel
                else None
            ),
            frontchannel_logout_uri=(
                config.url + config.logout.frontchannel.path
                if config.logout and config.logout.frontchannel
                else None
            ),
            grant_types=config.grants,
            post_logout_redirect_uris=(
                [config.url + path for path in config.logout.redirects]
                if config.logout
                else None
            ),
            redirect_uris=[config.url + config.callback],
            scope=" ".join(config.scopes) if config.scopes else None,
            token_endpoint_auth_method=(
                config.endpoints.token.auth
                if config.endpoints and config.endpoints.token
                else None
            ),
        )


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

        with open(self.config) as file:
            data = json.load(file)

        return Configuration(
            clients={
                id: ClientConfig.deserialize(config)
                for id, config in data.get("clients", {}).items()
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
        self.connection.request(
            method, f"{self.path}{path}", body=body, headers=headers or {}
        )
        response = self.connection.getresponse()

        if response.status >= 400:
            raise HTTPError(response.status, response.reason)

        return response

    def get(self, path: str) -> HTTPResponse:
        return self.request("GET", path)

    def post(self, path: str, body: dict) -> HTTPResponse:
        return self.request(
            "POST",
            path,
            body=json.dumps(body),
            headers={"Content-Type": "application/json"},
        )

    def put(self, path: str, body: dict) -> HTTPResponse:
        return self.request(
            "PUT",
            path,
            body=json.dumps(body),
            headers={"Content-Type": "application/json"},
        )

    def delete(self, path: str) -> HTTPResponse:
        return self.request("DELETE", path)

    def close(self) -> None:
        self.connection.close()

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *args, **kwargs) -> None:
        self.close()


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

    def create_client(self, request: CreateClientRequest) -> None:
        """Create a client."""

        with HTTPClient(self.url) as http:
            http.post("/admin/clients", body=request.serialize())

    def update_client(self, id: str, request: UpdateClientRequest) -> None:
        """Update a client."""

        with HTTPClient(self.url) as http:
            http.put(f"/admin/clients/{id}", body=request.serialize())

    def delete_client(self, id: str) -> None:
        """Delete a client."""

        with HTTPClient(self.url) as http:
            http.delete(f"/admin/clients/{id}")


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

    def __init__(self, hydra: HydraClient, configs: dict[str, ClientConfig]) -> None:
        self.hydra = hydra
        self.configs = configs

    def _list_clients(self) -> list[Client]:
        return self.hydra.list_clients()

    def _delete_client(self, id: str) -> None:
        try:
            self.hydra.delete_client(id)
        except (ConnectionError, HTTPError) as error:
            if isinstance(error, HTTPError) and error.status == HTTPStatus.NOT_FOUND:
                return

            logger.exception(f"Failed to delete client {id}.")
            raise SynchronizationError() from error

    def _update_client(self, id: str) -> None:
        config = self.configs[id]
        request = UpdateClientRequestBuilder().build(id, config)

        try:
            self.hydra.update_client(id, request)
        except (ConnectionError, HTTPError) as error:
            if isinstance(error, HTTPError) and error.status == HTTPStatus.NOT_FOUND:
                self._create_client(id)
                return

            logger.exception(f"Failed to update client {id}.")
            raise SynchronizationError() from error

    def _create_client(self, id: str) -> None:
        config = self.configs[id]
        request = CreateClientRequestBuilder().build(id, config)

        try:
            self.hydra.create_client(request)
        except (ConnectionError, HTTPError) as error:
            if isinstance(error, HTTPError) and error.status == HTTPStatus.CONFLICT:
                self._update_client(id)
                return

            logger.exception(f"Failed to create client {id}.")
            raise SynchronizationError() from error

    def synchronize(self) -> None:
        """Synchronize clients."""

        clients = self._list_clients()

        current = {client.client_id for client in clients}
        target = set(self.configs.keys())

        delete = current - target
        create = target - current
        update = current & target

        for id in delete:
            logger.info(f"Deleting client {id}...")
            self._delete_client(id)

        for id in update:
            logger.info(f"Updating client {id}...")
            self._update_client(id)

        for id in create:
            logger.info(f"Creating client {id}...")
            self._create_client(id)


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
        raise SynchronizationError()

    def synchronize(self) -> None:
        """Synchronize configuration."""

        logger.info("Synchronizing configuration...")

        self._wait_for_hydra()

        ClientSynchronizer(self.hydra, self.config.clients).synchronize()

        logger.info("Synchronization complete.")


def main() -> None:
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
