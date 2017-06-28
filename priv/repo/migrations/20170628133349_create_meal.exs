defmodule Alastair.Repo.Migrations.CreateMeal do
  use Ecto.Migration

  def change do
    create table(:meals) do
      add :name, :string
      add :time, :datetime

      timestamps()
    end

  end
end
