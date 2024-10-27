{{- define "diamond.sql.url" -}}
{{- $host := ( ds "config" ).diamond.sql.host -}}
{{- $port := ( ds "config" ).diamond.sql.port -}}
{{- $password := ( ds "config" ).diamond.sql.password -}}
cockroach://user:{{ print $password }}@{{ print $host }}:{{ print $port }}/database
{{- end -}}

{{- define "crocus.public.url" -}}
{{- $scheme := ( ds "config" ).crocus.public.scheme -}}
{{- $host := ( ds "config" ).crocus.public.host -}}
{{- $port := ( ds "config" ).crocus.public.port -}}
{{- $path := ( ds "config" ).crocus.public.path -}}
{{ print $scheme }}://{{ print $host }}{{ if test.IsKind "number" $port }}:{{ print $port }}{{ end }}{{ if test.IsKind "string" $path }}{{ print $path }}{{ end }}
{{- end -}}

# Controls the configuration for the http(s) daemon(s).
serve:
  # Controls the public daemon serving public API endpoints like /oauth2/auth, /oauth2/token, /.well-known/jwks.json.
  public:
    # The port to listen on.
    port: {{ ( ds "config" ).server.ports.public | conv.ToInt }}

    # The interface or unix socket Ory Hydra should listen and handle public API requests on. Use the prefix `unix:` to specify a path to a unix socket. Leave empty to listen on all interfaces.
    host: {{ ( ds "config" ).server.host | strings.Quote }}

  # Controls the admin daemon serving administrative endpoints.
  admin:
    # The port to listen on.
    port: {{ ( ds "config" ).server.ports.admin | conv.ToInt }}

    # The interface or unix socket Ory Hydra should listen and handle administrative API requests on. Use the prefix `unix:` to specify a path to a unix socket. Leave empty to listen on all interfaces.
    host: {{ ( ds "config" ).server.host | strings.Quote }}

  # Control cookies settings.
  cookies:
    # Specify the SameSite mode that cookies should be sent with.
    same_site_mode: Strict
    {{- if ( ds "config" ).cookies.domain }}

    # HTTP Cookie Domain
    # Sets the cookie domain for session and CSRF cookies. Useful when dealing with subdomains. Use with care!
    domain: {{ ( ds "config" ).cookies.domain | strings.Quote }}
    {{- end }}

    # Cookie Names
    # Sets the session cookie name. Use with care!
    names:
      # CSRF Cookie Name
      login_csrf: scorpion-login-csrf

      # CSRF Cookie Name
      consent_csrf: scorpion-consent-csrf

      # Session Cookie Name
      session: scorpion-session

# Sets the data source name. This configures the backend where Ory Hydra persists data. If dsn is `memory`, data will be written to memory and is lost when you restart this instance. Ory Hydra supports popular SQL databases. For more detailed configuration information go to: https://www.ory.sh/docs/hydra/dependencies-environment#sql
dsn: {{ template "diamond.sql.url" . | strings.Quote }}

# Configures ./well-known/ settings.
webfinger:
  # Configures OpenID Connect Discovery (/.well-known/openid-configuration).
  oidc_discovery:
    # A list of supported claims to be broadcasted. Claim `sub` is always included.
    supported_claims:
      - sub
      - name
      - picture
      - email
      - zoneinfo
      - locale

    # The scope OAuth 2.0 Clients may request. Scope `offline`, `offline_access`, and `openid` are always included.
    supported_scope:
      - openid
      - profile
      - email
      - offline
      - offline_access

# Controls URLs settings.
urls:
  # Controls the URLs about Ory Hydra itself.
  self:
    # This value will be used as the `issuer` in access and ID tokens. It must be specified and using HTTPS protocol, unless --dev is set. This should typically be equal to the public value.
    issuer: {{ ( ds "config" ).urls.issuer | strings.Quote }}

    # This is the base location of the public endpoints of your Ory Hydra installation. This should typically be equal to the issuer value. If left unspecified, it falls back to the issuer value.
    public: {{ ( ds "config" ).urls.public | strings.Quote }}

    # This is the base location of the admin endpoints of your Ory Hydra installation.
    admin: {{ ( ds "config" ).urls.admin | strings.Quote }}

  # Sets the OAuth2 Login Endpoint URL of the OAuth2 User Login & Consent flow. Defaults to an internal fallback URL showing an error.
  login: "{{ template "crocus.public.url" . }}/login"

  # Sets the OAuth2 Login Endpoint URL of the OAuth2 User Login & Consent flow. Defaults to an internal fallback URL showing an error.
  consent: "{{ template "crocus.public.url" . }}/consent"

  # Sets the logout endpoint. Defaults to an internal fallback URL showing an error.
  logout: "{{ template "crocus.public.url" . }}/logout"

  # Sets the error endpoint. The error ui will be shown when an OAuth2 error occurs that which can not be sent back to the client. Defaults to an internal fallback URL showing an error.
  error: "{{ template "crocus.public.url" . }}/error"

  # When a user agent requests to logout, it will be redirected to this url afterwards per default.
  post_logout_redirect: "{{ template "crocus.public.url" . }}/default"

# Controls OAuth 2.0 settings.
oauth2:
  # Set this to true if you want to share error debugging information with your OAuth 2.0 clients. Keep in mind that debug information is very valuable when dealing with errors, but might also expose database error codes and similar errors.
  expose_internal_errors: true

# The secrets section configures secrets used for encryption and signing of several systems. All secrets can be rotated, for more information on this topic go to: https://www.ory.sh/docs/hydra/advanced#rotation-of-hmac-token-signing-and-database-and-cookie-encryption-keys
secrets:
  # The system secret must be at least 16 characters long. If none is provided, one will be generated. They key is used to encrypt sensitive data using AES-GCM (256 bit) and validate HMAC signatures. The first item in the list is used for signing and encryption. The whole list is used for verifying signatures and decryption.
  system:
    {{- range ( ds "config" ).secrets.system }}
    - {{ . | strings.Quote }}
    {{- end }}

  # A secret that is used to encrypt cookie sessions. Defaults to secrets.system. It is recommended to use a separate secret in production. The first item in the list is used for signing and encryption. The whole list is used for verifying signatures and decryption.
  cookie:
    {{- range ( ds "config" ).secrets.cookie }}
    - {{ . | strings.Quote }}
    {{- end }}

# The Hydra version this config is written for.
# SemVer according to https://semver.org/ prefixed with `v` as in our releases.
version: v2.2.0
