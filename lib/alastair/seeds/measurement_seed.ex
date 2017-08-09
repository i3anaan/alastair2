defmodule Alastair.Seeds.MeasurementSeed do
	def run() do	
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

		%{pieces: pieces, ml: ml, l: l, g: g, kg: kg}
	end
end