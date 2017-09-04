defmodule Alastair.Meal do
  use Alastair.Web, :model

  schema "meals" do
    field :name, :string
    field :date, Ecto.Date
    field :time, Ecto.Time
    field :event_id, :string

    many_to_many :recipes, Alastair.Recipe, join_through: Alastair.MealRecipe
    has_many :meals_recipes, Alastair.MealRecipe, on_replace: :delete

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :event_id, :date, :time]) # TODO remove event_id from casts
    |> cast_assoc(:meals_recipes, required: false)
    |> validate_required([:name, :event_id, :date])
  end
end
