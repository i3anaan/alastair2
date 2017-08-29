# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Alastair.Repo.insert!(%Alastair.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

#currencies = Alastair.Seeds.CurrencySeed.run()
#measurements = Alastair.Seeds.MeasurementSeed.run()
#Alastair.Seeds.IngredientSeed.run(measurements)

try do
  measurements = Alastair.Repo.all(Alastair.Measurement)
  if Enum.empty?(measurements) do
    raise "empty"
  end
rescue
  _ -> Alastair.Seeds.ExampleSeed.run
end