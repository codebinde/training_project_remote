# OnlineMock

## Installation

See
[Getting Started with Elixir and Phoenix Applications - Installation](https://vorwerk.atlassian.net/wiki/spaces/DQA/pages/1831962812/Getting+Started+with+Elixir+and+Phoenix+Applications#Installation)
.

## Configuration

Create a file named `device.yml` (for example at `robot_framework/config/CUSTOM/`) and paste this content:

```
ONLINE_MOCK_HOSTNAME: 127.0.0.1
PATCH_ONLINE_SERVICE_HOSTNAME: false
SERVICE_PORT_BASE: 8080
REMOTE_LIB_PORT_OFFSET:
  online_mock: 5
ONLINE_MOCK_PORT_OFFSET:
  web: 10
  infrastructure: 11
  ocsp: 12
  est: 13
  cloud: 14
WEBSITE_INFLATION_KB: 0
```

## Start

See also
[Getting Started with Elixir and Phoenix Applications - Get Up and Running](https://vorwerk.atlassian.net/wiki/spaces/DQA/pages/1831962812/Getting+Started+with+Elixir+and+Phoenix+Applications#Get-Up-and-Running)
.

Before starting make sure an up to date version of `hex` and `rebar` is installed:

    $ mix local.hex --force
    $ mix local.rebar --force

*Remark:* These steps only need to be run once.

If you don't have already, please check out `testing/test_automation` repository and run the following commands (supposed
the repositories are located at `$HOME/Code/vorwerk/`).

    $ export TEST_AUTOMATION_DIR=$HOME/Code/vorwerk/test_automation
    $ export VARIABLEFILES=$HOME/Code/vorwerk/robot_framework/config/CUSTOM/device.yml

    $ cd $HOME/Code/vorwerk/robot_framework/services/online_mock
    $ mix deps.get

Finally run the server:

    $ mix phx.server

With the above configuration the following endpoints are available:

  | Endpoint                   | URL                       |
  | -------------------------- | ------------------------- |
  | `OnlineMockWeb`            | `https://127.0.0.1:8090/` |
  | `OnlineMockInfrastructure` | `http://127.0.0.1:8091/`  |
  | `OnlineMockOCSP`           | `http://127.0.0.1:8092/`  |
  | `OnlineMockEST`            | `https://127.0.0.1:8093/` |
  | `OnlineMockCloud`          | `https://127.0.0.1:8094/` |

## More

If you want to print the available routes, run:

    $ mix phx.routes

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
