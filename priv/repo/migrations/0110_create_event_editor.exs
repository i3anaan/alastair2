defmodule Alastair.Repo.Migrations.CreateEventEditor do
  use Ecto.Migration

  def change do
    create table(:event_editors) do
      add :event_id, :string
      add :value, :string
      add :permission_type, :permission_type
    end

  end
end
