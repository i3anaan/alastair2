defmodule Alastair.Recipe do
  use Alastair.Web, :model

  schema "recipes" do
    field :name, :string
    field :description, :string
    field :person_count, :integer
    field :instructions, :string
    field :avg_review, :float
    field :published, :boolean, default: false
    field :created_by, :string
    field :version, :integer, default: 0
    belongs_to :root_version, Alastair.Recipe

    many_to_many :meals, Alastair.Meal, join_through: Alastair.MealRecipe
    many_to_many :ingredients, Alastair.Ingredient, join_through: Alastair.RecipeIngredient
    has_many :recipes_ingredients, Alastair.RecipeIngredient
    has_many :reviews, Alastair.Review

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :person_count, :instructions, :published])
    |> validate_required([:name, :person_count, :instructions])
    |> validate_number(:person_count, greater_than: 0)
    |> validate_length(:name, min: 5, max: 100)
    |> validate_not_depublished
  end

  defp validate_not_depublished(changeset) do
    before_change = changeset.data.published
    after_change = Ecto.Changeset.get_change(changeset, :published, nil)

    if before_change == true && after_change == false do
      changeset
      |> Ecto.Changeset.add_error(:published, "Can not unpublish an already published recipe")
    else
      changeset
    end
  end

  def duplicate(original) do
    %Alastair.Recipe{
      name: original.name,
      description: original.description,
      person_count: original.person_count,
      instructions: original.instructions,
      published: original.published,
      created_by: original.created_by,
      version: original.version + 1,
      root_version_id: original.root_version_id
    }
  end
end
