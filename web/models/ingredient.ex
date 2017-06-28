defmodule Alastair.Ingredient do
  use Alastair.Web, :model

  schema "ingredients" do
    field :name, :string
    field :description, :string
    belongs_to :default_measurement, Alastair.DefaultMeasurement

    many_to_many :recipes, Alastair.Recipe, join_through: Alastair.RecipeIngredient

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description])
    |> validate_required([:name, :description])
  end
end
