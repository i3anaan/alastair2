defmodule Alastair.ShopAdmin do
  use Alastair.Web, :model

  schema "shop_admins" do
    field :user_id, :string
    belongs_to :shop, Alastair.Shop

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :shop_id])
    |> validate_required([:user_id, :shop_id])
    |> foreign_key_constraint(:shop_id)
    |> unique_constraint(:user_id, name: :shop_admins_shop_id_user_id_index)
  end
end
