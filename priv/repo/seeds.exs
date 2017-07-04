# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Alastair.Repo.insert!(%Alastair.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


ml = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Milliliter",
	plural_name: "Milliliters",
	display_code: "ml"
})

l = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Liter",
	plural_name: "Liters",
	display_code: "l"
})

g = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Gram",
	plural_name: "Grams",
	display_code: "g"
})

kg = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Kilogram",
	plural_name: "Kilograms",
	display_code: "kg"
})

pieces = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Piece",
	plural_name: "Pieces",
	display_code: "pc"
})

some = Alastair.Repo.insert!(%Alastair.Measurement{
	name: "Some",
	plural_name: "Some",
	display_code: ""
})


Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Cream",
	description: "Milkproduct",
	default_measurement: ml
})

Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Butter",
	description: "",
	default_measurement: g
})

oil = Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Olive Oil",
	description: "",
	default_measurement: ml
})

Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Sunflower Oil",
	description: "",
	default_measurement: ml
})

Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Water",
	description: "",
	default_measurement: ml
})

tomatoes = Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Tomatoes (fresh)",
	description: "",
	default_measurement: g
})

onions = Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Onions",
	description: "",
	default_measurement: g
})

spaghetti = Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Spaghetti",
	description: "",
	default_measurement: g
})

salt = Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Salt",
	description: "",
	default_measurement: some
})


Alastair.Repo.insert!(%Alastair.Ingredient{
	name: "Pepper",
	description: "",
	default_measurement: some
})

recipe1 = Alastair.Repo.insert!(%Alastair.Recipe{
	name: "Pasta with tomato sauce",
	description: "A simple pasta recipe",
	person_count: 4,
	instructions: "Chop and fry vegetables, add water and boil pasta"
})

Alastair.Repo.insert!(%Alastair.RecipeIngredient{
	recipe: recipe1,
	ingredient: spaghetti,
	quantity: 500.0
})

Alastair.Repo.insert!(%Alastair.RecipeIngredient{
	recipe: recipe1,
	ingredient: onions,
	quantity: 200.0
})

Alastair.Repo.insert!(%Alastair.RecipeIngredient{
	recipe: recipe1,
	ingredient: salt,
	quantity: 1.0
})

Alastair.Repo.insert!(%Alastair.RecipeIngredient{
	recipe: recipe1,
	ingredient: tomatoes,
	quantity: 400.0
})