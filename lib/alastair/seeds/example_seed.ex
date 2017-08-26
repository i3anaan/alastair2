defmodule Alastair.Seeds.ExampleSeed do
	def run() do
		currencies = Alastair.Seeds.CurrencySeed.run()
		measurements = Alastair.Seeds.MeasurementSeed.run()
		#Alastair.Seeds.IngredientSeed.run(measurements)

		# All following seeds are for testing purposes and should be removed
		%{:euro => euro} = currencies
		%{:ml => ml, :g => g} = measurements

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

		Alastair.Repo.insert!(%Alastair.Ingredient{
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
			default_measurement: g
		})


		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Pepper",
			description: "",
			default_measurement: g
		})

		recipe1 = Alastair.Repo.insert!(%Alastair.Recipe{
			name: "Pasta with tomato sauce",
			description: "A simple pasta recipe",
			person_count: 4,
			instructions: "Chop and fry vegetables, add water and boil pasta",
			created_by: "3",
			published: true
		})

		Alastair.Repo.insert!(%Alastair.RecipeIngredient{
			recipe: recipe1,
			ingredient: spaghetti,
			quantity: 500.0
		})

		Alastair.Repo.insert!(%Alastair.RecipeIngredient{
			recipe: recipe1,
			ingredient: onions,
			quantity: 200.0,
			comment: "Chop in dices"
		})

		Alastair.Repo.insert!(%Alastair.RecipeIngredient{
			recipe: recipe1,
			ingredient: salt,
			quantity: 1.0
		})

		Alastair.Repo.insert!(%Alastair.RecipeIngredient{
			recipe: recipe1,
			ingredient: tomatoes,
			quantity: 400.0,
			comment: "Use fresh ones here"
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
			person_count: 11
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
			price: 1.19,
			mapped_ingredient: spaghetti,
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.ShoppingItem{
			name: "Gut und Günstig Spaghetti",
			buying_quantity: 500.0,
			price: 0.39,
			mapped_ingredient: spaghetti,
			shop: shop1
		})

		fresh_tomatoes = Alastair.Repo.insert!(%Alastair.ShoppingItem{
			name: "Frische Tomaten",
			buying_quantity: 1000.0,
			flexible_amount: true,
			price: 2.39,
			mapped_ingredient: tomatoes,
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.ShoppingItem{
			name: "Frische Tomaten im Schälchen",
			buying_quantity: 500.0,
			flexible_amount: false,
			price: 1.69,
			mapped_ingredient: tomatoes,
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.ShoppingItem{
			name: "Zwiebel Sack",
			buying_quantity: 2500.0,
			flexible_amount: false,
			price: 1.39,
			mapped_ingredient: onions,
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.ShoppingItem{
			name: "Salz",
			buying_quantity: 500.0,
			flexible_amount: false,
			price: 0.29,
			mapped_ingredient: salt,
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.Event{
			id: "DevelopYourself3",
			shop: shop1
		})

		Alastair.Repo.insert!(%Alastair.ShoppingListNote{
			ticked: true,
			event_id: "DevelopYourself3",
			ingredient: tomatoes,
			shopping_item: fresh_tomatoes
		})
	end
end