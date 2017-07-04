defmodule Alastair.EventEditorTest do
  use Alastair.ModelCase

  alias Alastair.EventEditor

  @valid_attrs %{body_id: "some content", event_id: "some content", role_id: "some content", user_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EventEditor.changeset(%EventEditor{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EventEditor.changeset(%EventEditor{}, @invalid_attrs)
    refute changeset.valid?
  end
end
