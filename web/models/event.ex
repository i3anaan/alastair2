defmodule Alastair.Event do
  use Alastair.Web, :model

  schema "events" do
    field :oms_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:oms_id])
    |> validate_required([:oms_id])
  end
end
