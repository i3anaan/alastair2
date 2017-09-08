defmodule Alastair.Repo.Migrations.CreateIngredientRequest do
  use Ecto.Migration

  def change do
    create table(:ingredient_requests) do
      add :name, :string
      add :description, :string
      add :requested_by, :string
      add :admin_message, :string
      add :request_message, :string
      add :default_measurement_id, references(:measurements, on_delete: :nothing)
      add :approval_state, :approval_state

      timestamps()
    end
    create index(:ingredient_requests, [:default_measurement_id])

  end
end
