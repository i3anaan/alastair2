defmodule Alastair.Repo.Migrations.CreateShopAdmin do
  use Ecto.Migration

  def change do
    create table(:shop_admins) do
      add :user_id, :string
      add :shop_id, references(:shops, on_delete: :delete_all)

      timestamps()
    end

    create index(:shop_admins, [:shop_id])
    create unique_index(:shop_admins, [:shop_id, :user_id],  name: :shop_admins_shop_id_user_id_index)

  end
end
