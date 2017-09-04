defmodule Alastair.Admin do
  use Alastair.Web, :model

  schema "admins" do
    field :user_id, :string
    field :active, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :active])
    |> validate_required([:user_id])
  end
end
