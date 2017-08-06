defmodule Alastair.ShopTest do
  use Alastair.ModelCase

  alias Alastair.Shop

  @valid_attrs %{location: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Shop.changeset(%Shop{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Shop.changeset(%Shop{}, @invalid_attrs)
    refute changeset.valid?
  end
end
