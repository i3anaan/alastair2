defmodule Alastair.ShoppingItem do
  use Alastair.Web, :model

  schema "shopping_items" do
    field :comment, :string
    field :buying_quantity, :float
    field :price, :float
    belongs_to :buying_measurement, Alastair.BuyingMeasurement
    belongs_to :mapped_ingredient, Alastair.MappedIngredient
    belongs_to :shop, Alastair.Shop

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:comment, :buying_quantity, :price, :buying_measurement_id, :mapped_ingredient_id, :shop_id])
    |> validate_required([:comment, :buying_quantity, :price, :buying_measurement_id, :mapped_ingredient_id, :shop_id])
  end
end
