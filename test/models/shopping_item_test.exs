defmodule Alastair.ShoppingItemTest do
  use Alastair.ModelCase

  alias Alastair.ShoppingItem

  @valid_attrs %{buying_quantity: "120.5", comment: "some content", price: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ShoppingItem.changeset(%ShoppingItem{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ShoppingItem.changeset(%ShoppingItem{}, @invalid_attrs)
    refute changeset.valid?
  end
end
