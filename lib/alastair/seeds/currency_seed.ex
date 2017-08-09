defmodule Alastair.Seeds.CurrencySeed do
	def run() do	
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

		euro = Alastair.Repo.insert!(%Alastair.Currency{
			name: "Euro",
			display_code: "€"
		})

		%{euro: euro}
	end
end