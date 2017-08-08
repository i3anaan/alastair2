defmodule Alastair.EventEditor do
  use Alastair.Web, :model
  

  schema "event_editors" do
    field :event_id, :string
    field :value, :string
    field :permission_type, PermissionTypeEnum
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :user_id, :role_id, :body_id, :anyone, :admin])
    |> validate_required([:event_id, :admin])
  end
end
