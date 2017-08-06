defmodule Alastair.CurrencyView do
  use Alastair.Web, :view

  def render("index.json", %{currencies: currencies}) do
    %{data: render_many(currencies, Alastair.CurrencyView, "currency.json")}
  end

  def render("show.json", %{currency: currency}) do
    %{data: render_one(currency, Alastair.CurrencyView, "currency.json")}
  end

  def render("currency.json", %{currency: currency}) do
    %{id: currency.id,
      name: currency.name,
      display_code: currency.display_code}
  end
end
