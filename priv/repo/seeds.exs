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

euro = Alastair.Repo.insert!(%Alastair.Currency{
	name: "Euro",
	display_code: "€"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Romanian Lei",
	display_code: "lei"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Hungarian forint",
	display_code: "Ft"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "US Dollar",
	display_code: "$"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Swiss Franc",
	display_code: "Fr"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Bulgarian lev",
	display_code: "лв"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "British Pound",
	display_code: "£"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Ukrainian hryvnia",
	display_code: "₴"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Turkish lira",
	display_code: "₺"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Russian ruble",
	display_code: "₽"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Moldovan leu",
	display_code: "L"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Czech koruna",
	display_code: "Kč"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Polish złoty",
	display_code: "zł"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Danish krone",
	display_code: "kr"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Croatian kuna",
	display_code: "kn"
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Serbian dinar",
	display_code: "din."
})

Alastair.Repo.insert!(%Alastair.Currency{
	name: "Swedish krona",
	display_code: "kr"
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

Alastair.Repo.insert!(%Alastair.Review{
	user_id: "testtest",
	review: "Pretty neat recipe, I recommend. Lacks garlic though",
	rating: 4,
	recipe: recipe1
})

Alastair.RecipeController.update_avg_review(recipe1.id)

meal1 = Alastair.Repo.insert!(%Alastair.Meal{
	name: "Dinner",
	event_id: "DevelopYourself3",
})

Alastair.Repo.insert!(%Alastair.MealRecipe{
	meal: meal1,
	recipe: recipe1,
	person_count: 10
})

shop1 = Alastair.Repo.insert!(%Alastair.Shop{
	name: "Aldi",
	location: "Dresden",
	currency: euro
})

shop2 = Alastair.Repo.insert!(%Alastair.Shop{
	name: "Edeka",
	location: "Dresden",
	currency: euro
})

Alastair.Repo.insert!(%Alastair.ShoppingItem{
	name: "Barilla Spaghetti",
	buying_quantity: 500.0,
	buying_measurement: g,
	price: 1.19,
	mapped_ingredient: spaghetti,
	shop: shop1
})

Alastair.Repo.insert!(%Alastair.ShoppingItem{
	name: "Gut und Günstig Spaghetti",
	buying_quantity: 500.0,
	buying_measurement: g,
	price: 0.39,
	mapped_ingredient: spaghetti,
	shop: shop1
})

Alastair.Repo.insert!(%Alastair.ShoppingItem{
	name: "Frische Tomaten",
	buying_quantity: 1000.0,
	flexible_amount: true,
	buying_measurement: g,
	price: 2.39,
	mapped_ingredient: tomatoes,
	shop: shop1
})

Alastair.Repo.insert!(%Alastair.ShoppingItem{
	name: "Frische Tomaten im Schälchen",
	buying_quantity: 500.0,
	flexible_amount: false,
	buying_measurement: g,
	price: 1.69,
	mapped_ingredient: tomatoes,
	shop: shop1
})