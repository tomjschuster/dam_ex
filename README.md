# DamEx

DamEx is an open source Digital Asset Manager built in Elixir and Elm with adapters for multiple storage sources.

So far there is only an S3 adapter and a basic UI without any users/authentication.

## Run locally

### Prerequisites

- [Elixir](https://elixir-lang.org/)
- [Node.js](https://nodejs.org/)
- [Elm](https://elm-lang.org/)
- [PostgreSQL](https://www.postgresql.org/)

### Install and run

```sh
mix deps.get
mix ecto.setup
cd assets
npm install
cd ..
mix phx.server
```

Open your browser to http://localhost:4000

## TODO

- Storage Adapters: local, Azure Blob Storage, Google Cloud Storage
- Users
- Metadata: Image dimensions, tags
- Search
- Bulk edit/delete
- UI: Styling, File Preview
