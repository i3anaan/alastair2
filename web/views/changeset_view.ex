defmodule Alastair.ChangesetView do
  use Alastair.Web, :view

  @doc """
  Traverses and translates changeset errors.

  See `Ecto.Changeset.traverse_errors/2` and
  `Alastair.ErrorHelpers.translate_error/1` for more details.
  """
#  def translate_errors(changeset) when is_list(changeset) do
#    Enum.map(changeset, fn(x) -> Ecto.Changeset.traverse_errors(x, &translate_error/1) end)
#  end

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end

end
