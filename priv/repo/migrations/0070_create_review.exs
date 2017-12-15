defmodule Alastair.Repo.Migrations.CreateReview do
  use Ecto.Migration

  def change do
    create table(:reviews) do
      add :rating, :integer
      add :review, :text
      add :recipe_id, references(:recipes, on_delete: :delete_all)
      add :user_id, :string

      timestamps()
    end
    create index(:reviews, [:recipe_id])

  end
end
