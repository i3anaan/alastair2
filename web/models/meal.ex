defmodule Alastair.Meal do
  use Alastair.Web, :model

  schema "meals" do
    field :name, :string
    field :time, Ecto.DateTime
    field :event_id, :string

    many_to_many :recipes, Alastair.Recipe, join_through: Alastair.MealRecipe
    has_many :meals_recipes, Alastair.MealRecipe

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :event_id])
    |> validate_required([:name, :event_id])
  end
end
