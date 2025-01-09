# Cofiguration for the server
server:
  # Host to run the server on
  host: {{ env.Getenv "SCORPION__SERVER__HOST" "0.0.0.0" | strings.Quote }}

  # Configuration for server ports
  ports:
    # Port for public traffic
    public: {{ env.Getenv "SCORPION__SERVER__PORTS__PUBLIC" "20000" | conv.ToInt }}

    # Port for admin traffic
    admin: {{ env.Getenv "SCORPION__SERVER__PORTS__ADMIN" "20001" | conv.ToInt }}

# Configuration for the URLs
urls:
  # Issuer URL
  issuer: {{ env.Getenv "SCORPION__URLS__ISSUER" "http://localhost:20000" | strings.Quote }}

  # Public URL
  public: {{ env.Getenv "SCORPION__URLS__PUBLIC" "http://localhost:20000" | strings.Quote }}

  # Admin URL
  admin: {{ env.Getenv "SCORPION__URLS__ADMIN" "http://localhost:20001" | strings.Quote }}

# Configuration for the secrets
secrets:
  # System secrets
  system:
    {{- range ( env.Getenv "SCORPION__SECRETS__SYSTEM" "secretsecretsecret" | strings.Split "," ) }}
    - {{ . | strings.Quote }}
    {{- end }}

  # Cookie secrets
  cookie:
    {{- range ( env.Getenv "SCORPION__SECRETS__COOKIE" "secretsecretsecret" | strings.Split "," ) }}
    - {{ . | strings.Quote }}
    {{- end }}

# Configuration for the crocus app
crocus:
  # Configuration for the public site of the crocus app
  public:
    # Scheme of the public site
    scheme: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__SCHEME" "http" | strings.Quote }}

    # Host of the public site
    host: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__HOST" "localhost" | strings.Quote }}

    # Port of the public site
    port: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__PORT" "20020" | default "null" }}

    # Path of the public site
    path: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__PATH" | strings.Quote | strings.TrimPrefix `""` | default "null" }}

# Configuration for the diamond database
diamond:
  # Configuration for the SQL API of the diamond database
  sql:
    # Host of the SQL API
    host: {{ env.Getenv "SCORPION__DIAMOND__SQL__HOST" "localhost" | strings.Quote }}

    # Port of the SQL API
    port: {{ env.Getenv "SCORPION__DIAMOND__SQL__PORT" "20010" | conv.ToInt }}

    # Password to authenticate with the SQL API
    password: {{ env.Getenv "SCORPION__DIAMOND__SQL__PASSWORD" "password" | strings.Quote }}

# Configuration for the clients
clients:
  # Configuration for the aster client
  aster:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__ASTER__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__ASTER__URL" "http://localhost:10110" | strings.Quote }}

  # Configuration for the daisy client
  daisy:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__DAISY__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__DAISY__URL" "http://localhost:10810" | strings.Quote }}

  # Configuration for the jasmine client
  jasmine:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__JASMINE__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__JASMINE__URL" "http://localhost:10620" | strings.Quote }}

  # Configuration for the lotus client
  lotus:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__LOTUS__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__LOTUS__URL" "http://localhost:10230" | strings.Quote }}

  # Configuration for the magnolia client
  magnolia:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__MAGNOLIA__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__MAGNOLIA__URL" "http://localhost:10720" | strings.Quote }}

  # Configuration for the poppy client
  poppy:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__POPPY__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__POPPY__URL" "http://localhost:10410" | strings.Quote }}

  # Configuration for the tulip client
  tulip:
    # Callback path
    callback: /api/auth/callback/scorpion

    # Configuration for scorpion endpoints
    endpoints:
      # Configuration for token endpoint
      token:
        # Authentication method
        auth: client_secret_basic

    # Supported grant types
    grants:
      - authorization_code
      - refresh_token

    # Configuration for logout
    logout:
      # Configuration for front-channel logout
      frontchannel:
        # Path of the front-channel logout endpoint
        path: /auth/logout/frontchannel

        # Whether to pass iss and sid parameters
        session: true

      # Allowed redirect paths after logout
      redirects:
        - ""

    # Supported scopes
    scopes:
      - openid
      - profile
      - email
      - offline_access

    # Secret of the client
    secret: {{ env.Getenv "SCORPION__CLIENTS__TULIP__SECRET" "secret" | strings.Quote }}

    # Public URL
    url: {{ env.Getenv "SCORPION__CLIENTS__TULIP__URL" "http://localhost:10530" | strings.Quote }}

# Enable debug mode
debug: {{ env.Getenv "SCORPION__DEBUG" "true" | conv.ToBool }}
