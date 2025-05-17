defmodule GatewayWeb.Router do
  use GatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GatewayWeb do
    pipe_through :api

    post "/test", TestAPIController, :process
    get "/test", TestAPIController, :process
    post "/users", UsersController, :create
    get "/users/:id", UsersController, :show
  end
end
