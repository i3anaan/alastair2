defmodule Alastair.ShoppingItem do
  use Alastair.Web, :model

  schema "shopping_items" do
    field :name, :string
    field :comment, :string
    field :buying_quantity, :float
    field :flexible_amount, :boolean, default: false
    field :price, :float
    belongs_to :buying_measurement, Alastair.Measurement
    belongs_to :mapped_ingredient, Alastair.Ingredient
    belongs_to :shop, Alastair.Shop

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :comment, :buying_quantity, :flexible_amount, :price, :buying_measurement_id, :mapped_ingredient_id, :shop_id])
    |> validate_required([:name, :buying_quantity, :price, :flexible_amount, :buying_measurement_id, :mapped_ingredient_id, :shop_id])
    |> foreign_key_constraint([:buying_measurement_id,  :mapped_ingredient_id, :shop_id])
  end
end
