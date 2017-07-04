defmodule Alastair.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :time, :utc_datetime

      add :event_id, references(:events, on_delete: :nothing)


      timestamps()
    end
    create index(:meals, [:event_id])

  end
end
