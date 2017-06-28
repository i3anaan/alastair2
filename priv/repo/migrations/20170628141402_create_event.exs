defmodule Alastair.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :oms_id, :string

      timestamps()
    end

  end
end
