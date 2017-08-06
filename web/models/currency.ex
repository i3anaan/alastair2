defmodule Alastair.Currency do
  use Alastair.Web, :model

  schema "currencies" do
    field :name, :string
    field :display_code, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :display_code])
    |> validate_required([:name, :display_code])
  end
end
