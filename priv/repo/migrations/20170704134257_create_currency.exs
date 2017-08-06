defmodule Alastair.Repo.Migrations.CreateCurrency do
  use Ecto.Migration

  def change do
    create table(:currencies) do
      add :name, :string
      add :display_code, :string

      timestamps()
    end

  end
end
