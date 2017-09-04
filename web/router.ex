defmodule Alastair.Router do
  use Alastair.Web, :router

  def fetch_user(conn, _) do
    user_service = Application.get_env(:alastair, Alastair.Endpoint)[:user_service]
    apply(Alastair.UserService, user_service, [conn])
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_user
  end

  pipeline :general do
    plug :accepts, ["json"]
  end


  scope "/", Alastair do
      get "/status", GeneralController, :status
  end



  # Other scopes may use custom stacks.
  scope "/api", Alastair do
    pipe_through :api

    get "/user", AdminController, :own_user
    resources "/admins", AdminController, except: [:new, :edit, :update]
    put "/admins/:id", AdminController, :set_active

    scope "/events/:event_id", as: :event do
      resources "/meals", MealController, except: [:new, :edit]
      get "/shopping_list", ShoppingListController, :shopping_list
      put "/shopping_list/note/:ingredient_id", ShoppingListController, :put_note
    end

    resources "/events", EventController, only: [:index, :show, :update]

    resources "/recipes", RecipeController, except: [:new, :edit] do
      resources "/reviews", ReviewController, except: [:new, :edit]
    end
    get "/my_recipes", RecipeController, :index_mine
    resources "/ingredients", IngredientController, except: [:new, :edit]

    resources "/shops", ShopController, except: [:new, :edit] do
      resources "/shopping_items", ShoppingItemController, except: [:new, :edit]
      resources "/admins", ShopAdminController, only: [:index, :create, :delete]
      get "/user", ShopAdminController, :own_user
    end
   

    resources "/currencies", CurrencyController, only: [:index]
    resources "/measurements", MeasurementController, only: [:index]
  end
end
