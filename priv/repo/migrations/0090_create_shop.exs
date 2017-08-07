defmodule Alastair.Repo.Migrations.CreateShop do
  use Ecto.Migration

  def change do
    create table(:shops) do
      add :name, :string
      add :location, :string
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end
    create index(:shops, [:currency_id])

  end
end
