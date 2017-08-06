defmodule Alastair.CurrencyTest do
  use Alastair.ModelCase

  alias Alastair.Currency

  @valid_attrs %{display_code: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Currency.changeset(%Currency{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Currency.changeset(%Currency{}, @invalid_attrs)
    refute changeset.valid?
  end
end
