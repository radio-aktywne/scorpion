---
slug: /configuration
title: Configuration
---

## Environment variables

You can configure the service at runtime using various environment variables:

- `SCORPION__SERVER__HOST` -
  host to run the server on
  (default: `0.0.0.0`)
- `SCORPION__SERVER__PORTS__PUBLIC` -
  port for public traffic
  (default: `20000`)
- `SCORPION__SERVER__PORTS__ADMIN` -
  port for admin traffic
  (default: `20001`)
- `SCORPION__URLS__ISSUER` -
  issuer URL
  (default: `http://localhost:20000`)
- `SCORPION__URLS__PUBLIC` -
  public URL
  (default: `http://localhost:20000`)
- `SCORPION__URLS__ADMIN` -
  admin URL
  (default: `http://localhost:20001`)
- `SCORPION__SECRETS__SYSTEM` -
  system secrets
  (default: `secretsecretsecret`)
- `SCORPION__SECRETS__COOKIE` -
  cookie secrets
  (default: `secretsecretsecret`)
- `SCORPION__CROCUS__PUBLIC__SCHEME` -
  scheme of the public site of the crocus app
  (default: `http`)
- `SCORPION__CROCUS__PUBLIC__HOST` -
  host of the public site of the crocus app
  (default: `localhost`)
- `SCORPION__CROCUS__PUBLIC__PORT` -
  port of the public site of the crocus app
  (default: `20020`)
- `SCORPION__CROCUS__PUBLIC__PATH` -
  path of the public site of the crocus app
  (default: ``)
- `SCORPION__DIAMOND__SQL__HOST` -
  host of the SQL API of the diamond database
  (default: `localhost`)
- `SCORPION__DIAMOND__SQL__PORT` -
  port of the SQL API of the diamond database
  (default: `20010`)
- `SCORPION__DIAMOND__SQL__PASSWORD` -
  password to authenticate with the SQL API of the diamond database
  (default: `password`)
- `SCORPION__CLIENTS__ASTER__SECRET` -
  secret of the aster client
  (default: `secret`)
- `SCORPION__CLIENTS__ASTER__URL` -
  public URL of the aster app
  (default: `http://localhost:10110`)
- `SCORPION__CLIENTS__DAISY__SECRET` -
  secret of the daisy client
  (default: `secret`)
- `SCORPION__CLIENTS__DAISY__URL` -
  public URL of the daisy app
  (default: `http://localhost:10810`)
- `SCORPION__CLIENTS__JASMINE__SECRET` -
  secret of the jasmine client
  (default: `secret`)
- `SCORPION__CLIENTS__JASMINE__URL` -
  public URL of the jasmine app
  (default: `http://localhost:10620`)
- `SCORPION__CLIENTS__LOTUS__SECRET`
  secret of the lotus client
  (default: `secret`)
- `SCORPION__CLIENTS__LOTUS__URL` -
  public URL of the lotus app
  (default: `http://localhost:10230`)
- `SCORPION__CLIENTS__MAGNOLIA__SECRET` -
  secret of the magnolia client
  (default: `secret`)
- `SCORPION__CLIENTS__MAGNOLIA__URL` -
  public URL of the magnolia app
  (default: `http://localhost:10720`)
- `SCORPION__CLIENTS__POPPY__SECRET` -
  secret of the poppy client
  (default: `secret`)
- `SCORPION__CLIENTS__POPPY__URL` -
  public URL of the poppy app
  (default: `http://localhost:10410`)
- `SCORPION__CLIENTS__TULIP__SECRET` -
  secret of the tulip client
  (default: `secret`)
- `SCORPION__CLIENTS__TULIP__URL` -
  public URL of the tulip app
  (default: `http://localhost:10530`)
- `SCORPION__DEBUG` -
  enable debug mode
  (default: `true`)
