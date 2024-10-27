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

# Configuration for the cookies
cookies:
  # Domain for the cookies
  domain: {{ env.Getenv "SCORPION__COOKIES__DOMAIN" | strings.Quote | strings.TrimPrefix `""` | default "null" }}

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

# Enable debug mode
debug: {{ env.Getenv "SCORPION__DEBUG" "true" | conv.ToBool }}
