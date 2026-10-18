# Apito Studio

One Docker image with the Apito engine and console.

```bash
curl -fsSL https://get.apito.io/install.sh | bash
apito start
```

Homebrew:

```bash
brew tap apito-io/tap
brew install apito-cli
apito start
```

`apito start` pulls `ghcr.io/apito-io/studio`.

The console is at http://localhost:4055. The engine API is at http://localhost:5055.

Data is stored in `~/.apito/db` and mounted at `/data` in the container.

Pin a Studio image with `studio_version` in `~/.apito/config.yml`. `pins.json` lists the engine and console refs baked into a release.

Supported databases are SQLite, PostgreSQL, MySQL, MariaDB, and MongoDB. DynamoDB, Oracle, and Cassandra are coming soon.

- https://apito.io
- https://apito.io/docs
- https://discord.gg/Xb7p2ddC6E
- support@apito.io

Licensed under AGPL-3.0. You can use, modify and self-host it. If you run a modified version as a network service, you must publish your changes under AGPL-3.0. A commercial license is available from Apito LLC. Releases v1.8.26 to v1.8.30 remain FSL-1.1-ALv2; see LICENSING.md.
