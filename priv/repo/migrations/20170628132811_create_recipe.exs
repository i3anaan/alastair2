defmodule Alastair.Repo.Migrations.CreateRecipe do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :description, :text
      add :person_count, :integer
      add :instructions, :text
      add :database_id, references(:databases, on_delete: :nothing)

      timestamps()
    end
    create index(:recipes, [:database_id])

  end
end
