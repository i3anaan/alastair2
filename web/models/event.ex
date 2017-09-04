defmodule Alastair.Event do
  use Alastair.Web, :model

  @primary_key {:id, :string, []}
  @derive {Phoenix.Param, key: :id}
  schema "events" do
    belongs_to :shop, Alastair.Shop, on_replace: :nilify

    has_many :meals, Alastair.Meal
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:shop_id])
    |> validate_required([:id])
    |> foreign_key_constraint(:shop_id)
  end
end
