#/bin/ash

mix deps.get
npm install
mix ecto.create
mix ecto.migrate
