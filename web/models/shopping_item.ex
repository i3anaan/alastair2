defmodule Alastair.ShoppingItem do
  use Alastair.Web, :model

  schema "shopping_items" do
    field :name, :string
    field :comment, :string
    field :buying_quantity, :float
    field :flexible_amount, :boolean, default: false
    field :price, :float
    belongs_to :mapped_ingredient, Alastair.Ingredient
    belongs_to :shop, Alastair.Shop

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :comment, :buying_quantity, :flexible_amount, :price, :mapped_ingredient_id, :shop_id])
    |> validate_required([:name, :buying_quantity, :price, :flexible_amount, :mapped_ingredient_id, :shop_id])
    |> foreign_key_constraint(:mapped_ingredient_id)
    |> foreign_key_constraint(:shop_id)
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_number(:buying_quantity, greater_than: 0)
  end
end
