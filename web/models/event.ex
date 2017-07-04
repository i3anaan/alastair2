defmodule Alastair.Event do
  use Alastair.Web, :model

  @primary_key {:id, :string, []}
  @derive {Phoenix.Param, key: :id}
  schema "events" do
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id])
    |> validate_required([:id])
  end
end
