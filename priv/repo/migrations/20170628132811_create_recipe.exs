defmodule Alastair.Repo.Migrations.CreateRecipe do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :description, :text
      add :person_count, :integer
      add :instructions, :text

      timestamps()
    end

  end
end
