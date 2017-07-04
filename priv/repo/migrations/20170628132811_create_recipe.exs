defmodule Alastair.Repo.Migrations.CreateRecipe do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :description, :text
      add :person_count, :integer
      add :instructions, :text

      add :avg_review, :float

      timestamps()
    end

  end
end
