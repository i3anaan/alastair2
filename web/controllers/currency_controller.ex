defmodule Alastair.CurrencyController do
  use Alastair.Web, :controller

  alias Alastair.Currency

  def index(conn, _params) do
    currencies = Repo.all(Currency)
    render(conn, "index.json", currencies: currencies)
  end

end
