defmodule Alastair.Repo.Migrations.CreateEvent do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :string, primary_key: true
    end

  end
end
