defmodule Alastair.IngredientRequest do
  use Alastair.Web, :model

  schema "ingredient_requests" do
    field :name, :string
    field :description, :string
    field :requested_by, :string
    field :admin_message, :string
    field :request_message, :string
    belongs_to :default_measurement, Alastair.Measurement
    field :approval_state, ApprovalStateEnum, default: :requesting

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :requested_by, :request_message, :default_measurement_id, :admin_message, :approval_state])
    |> validate_required([:name, :requested_by, :default_measurement_id])
    |> foreign_key_constraint(:default_measurement_id)
    |> validate_not_reapproved
  end

  defp validate_not_reapproved(changeset) do
    before_change = changeset.data.approval_state
    after_change = Ecto.Changeset.get_change(changeset, :approval_state, nil)

    if after_change != nil && before_change != :requesting do
      changeset
      |> Ecto.Changeset.add_error(:approval_state, "Can not undo an approval decision, you have to submit a new request")
    else
      changeset
    end
  end
end
