defmodule Alastair.Repo.Migrations.CreateShopAdmin do
  use Ecto.Migration

  def change do
    create table(:shop_admins) do
      add :user_id, :string
      add :shop_id, references(:shops, on_delete: :nothing)

      timestamps()
    end

    create index(:shop_admins, [:shop_id])
  end
end
