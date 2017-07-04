defmodule Alastair.Review do
  use Alastair.Web, :model

  schema "reviews" do
    field :rating, :integer
    field :review, :string
    belongs_to :recipe, Alastair.Recipe

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:rating, :review])
    |> validate_required([:rating, :review])
  end
end
