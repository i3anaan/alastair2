#/bin/ash

if [ "$MIX_ENV" = "prod" ]; then
  mkdir -p priv/static
  mix deps.get --only prod
  mix compile

  brunch build --production
  mix phoenix.digest
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
else
  mkdir -p priv/static
  mix deps.get
  npm install
  brunch build
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
fi