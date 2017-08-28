defmodule Alastair.Repo.Migrations.CreateAdmins do
  use Ecto.Migration

  def change do
    create table(:admins) do
      add :user_id, :string

      timestamps()
    end
  end
end
