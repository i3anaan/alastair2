defmodule Alastair.Repo.Migrations.CreateMeasurement do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :name, :string
      add :plural_name, :string
      add :display_code, :string

      timestamps()
    end

  end
end
