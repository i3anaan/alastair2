defmodule Alastair.Meal do
  use Alastair.Web, :model

  schema "meals" do
    field :name, :string
    field :time, Ecto.DateTime

    many_to_many :recipes, Alastair.Recipe, join_through: Alastair.MealRecipe

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :time])
    |> validate_required([:name, :time])
  end
end
