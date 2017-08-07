defmodule Alastair.Repo.Migrations.CreateIngredient do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :name, :string
      add :description, :text
      add :default_measurement_id, references(:measurements, on_delete: :nothing)

      timestamps()
    end
    create index(:ingredients, [:default_measurement_id])

  end
end
