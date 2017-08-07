defmodule Alastair.Repo.Migrations.CreateEventEditor do
  use Ecto.Migration

  def change do
    create table(:event_editors) do
      add :event_id, :string
      add :user_id, :string
      add :role_id, :string
      add :body_id, :string
      add :anyone, :boolean

      add :admin, :boolean
    end

  end
end
