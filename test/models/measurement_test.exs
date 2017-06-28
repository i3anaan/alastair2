defmodule Alastair.MeasurementTest do
  use Alastair.ModelCase

  alias Alastair.Measurement

  @valid_attrs %{display_code: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @invalid_attrs)
    refute changeset.valid?
  end
end
