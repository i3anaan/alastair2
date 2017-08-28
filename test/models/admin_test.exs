defmodule Alastair.AdminTest do
  use Alastair.ModelCase

  alias Alastair.Admin

  @valid_attrs %{user_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Admin.changeset(%Admin{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Admin.changeset(%Admin{}, @invalid_attrs)
    refute changeset.valid?
  end
end
