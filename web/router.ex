defmodule Alastair.Router do
  use Alastair.Web, :router

  def fetch_user(conn, _) do
    assign(conn, :user, %{id: "asd123", first_name: "Nico", last_name: "Westerbeck", superadmin: false})
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_user
  end

  # Other scopes may use custom stacks.
  scope "/api", Alastair do
    pipe_through :api

    scope "/events/:event_id", as: :event do
      resources "/meals", MealController, except: [:new, :edit]
      get "/shopping_list", ShoppingListController, :shopping_list
    end

    resources "/events", EventController, only: [:show, :update]

    resources "/recipes", RecipeController, except: [:new, :edit] do
      resources "/reviews", ReviewController, except: [:new, :edit]
    end
    resources "/ingredients", IngredientController, except: [:new, :edit]

    resources "/shops", ShopController, except: [:new, :edit] do
      resources "/shopping_items", ShoppingItemController, except: [:new, :edit]
    end
    resources "/currencies", CurrencyController, only: [:index]
    resources "/measurements", MeasurementController, only: [:index]
  end
end
