defmodule Alastair.Seeds.IngredientSeed do
	def run(measurements) do
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

		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Tomatoes",
			description: "",
			default_measurement: g
		})

		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Onions",
			description: "",
			default_measurement: g
		})

		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Spaghetti",
			description: "",
			default_measurement: g
		})

		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Salt",
			description: "",
			default_measurement: g
		})


		Alastair.Repo.insert!(%Alastair.Ingredient{
			name: "Pepper",
			description: "",
			default_measurement: g
		})
	end
end