defmodule Alastair.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :string, primary_key: true
      add :shop_id, references(:shops, on_delete: :nilify_all)
    end
    create index(:events, [:shop_id])
  end
end
