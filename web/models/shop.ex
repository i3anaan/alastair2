defmodule Alastair.Shop do
  use Alastair.Web, :model

  schema "shops" do
    field :name, :string
    field :location, :string
    belongs_to :currency, Alastair.Currency

    has_many :shopping_items, Alastair.ShoppingItem
    has_many :shop_admins, Alastair.ShopAdmin

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :location, :currency_id])
    |> validate_required([:name, :currency_id])
    |> foreign_key_constraint(:currency_id)
  end
end
