defmodule Alastair.Ingredient do
  use Alastair.Web, :model

  schema "ingredients" do
    field :name, :string
    field :description, :string
    belongs_to :default_measurement, Alastair.Measurement

    many_to_many :recipes, Alastair.Recipe, join_through: Alastair.RecipeIngredient
    has_many :mapped_shopping_items, Alastair.ShoppingItem

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :default_measurement_id])
    |> validate_required([:name, :default_measurement_id])
    |> validate_length(:name, min: 2, max: 60)
    |> validate_length(:description, max: 100)
    |> foreign_key_constraint(:default_measurement_id)
  end
end
