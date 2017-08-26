defmodule Alastair.ShoppingListNote do
  use Alastair.Web, :model

  schema "shopping_list_notes" do
    field :event_id, :string
    field :ticked, :boolean
    field :bought, :float
    belongs_to :ingredient, Alastair.Ingredient
    belongs_to :shopping_item, Alastair.ShoppingItem

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ticked, :bought, :shopping_item_id])
    |> validate_required([:event_id, :ingredient_id])
    |> foreign_key_constraint(:ingredient_id)
  end
end
