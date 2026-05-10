# Configuration for clients
clients:
{{ env.Getenv "SCORPION__CLIENTS" "{}" | data.JSON | data.ToYAML | strings.TrimSpace | strings.Indent 2 }}

# Configuration for crocus app
crocus:
  # Configuration for public site of crocus app
  public:
    # Host of public site
    host: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__HOST" "localhost" | strings.Quote }}

    # Path of public site
    path: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__PATH" | strings.Quote | strings.TrimPrefix `""` | default "null" }}

    # Port of public site
    port: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__PORT" "20020" | default "null" }}

    # Scheme of public site
    scheme: {{ env.Getenv "SCORPION__CROCUS__PUBLIC__SCHEME" "http" | strings.Quote }}

# Enable debug mode
debug: {{ env.Getenv "SCORPION__DEBUG" "true" | conv.ToBool }}

# Configuration for diamond database
diamond:
  # Configuration for SQL API of diamond database
  sql:
    # Host of SQL API
    host: {{ env.Getenv "SCORPION__DIAMOND__SQL__HOST" "localhost" | strings.Quote }}

    # Password to authenticate with SQL API
    password: {{ env.Getenv "SCORPION__DIAMOND__SQL__PASSWORD" "password" | strings.Quote }}

    # Port of SQL API
    port: {{ env.Getenv "SCORPION__DIAMOND__SQL__PORT" "20010" | conv.ToInt }}

# Configuration for secrets
secrets:
  # Cookie secrets
  cookie:
    {{- range ( env.Getenv "SCORPION__SECRETS__COOKIE" "secretsecretsecret" | strings.Split "," ) }}
    - {{ . | strings.Quote }}
    {{- end }}

  # System secrets
  system:
    {{- range ( env.Getenv "SCORPION__SECRETS__SYSTEM" "secretsecretsecret" | strings.Split "," ) }}
    - {{ . | strings.Quote }}
    {{- end }}

# Configuration for server
server:
  # Host to run the server on
  host: {{ env.Getenv "SCORPION__SERVER__HOST" "0.0.0.0" | strings.Quote }}

  # Configuration for server ports
  ports:
    # Port for admin traffic
    admin: {{ env.Getenv "SCORPION__SERVER__PORTS__ADMIN" "20001" | conv.ToInt }}

    # Port for public traffic
    public: {{ env.Getenv "SCORPION__SERVER__PORTS__PUBLIC" "20000" | conv.ToInt }}

# Configuration for URLs
urls:
  # Admin URL
  admin: {{ env.Getenv "SCORPION__URLS__ADMIN" "http://localhost:20001" | strings.Quote }}

  # Issuer URL
  issuer: {{ env.Getenv "SCORPION__URLS__ISSUER" "http://localhost:20000" | strings.Quote }}

  # Public URL
  public: {{ env.Getenv "SCORPION__URLS__PUBLIC" "http://localhost:20000" | strings.Quote }}
