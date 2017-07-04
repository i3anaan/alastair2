defmodule Alastair.Measurement do
  use Alastair.Web, :model

  schema "measurements" do
    field :name, :string
    field :plural_name, :string
    field :display_code, :string

    has_many :ingredients, Alastair.Ingredient

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :plural_name, :display_code])
    |> validate_required([:name, :plural_name, :display_code])
  end
end
