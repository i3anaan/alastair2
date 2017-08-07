defmodule Alastair.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :time, :utc_datetime

      add :event_id, :string


      timestamps()
    end

  end
end
