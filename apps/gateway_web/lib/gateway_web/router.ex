defmodule GatewayWeb.Router do
  use GatewayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GatewayWeb do
    pipe_through :api

    post "/test", TestAPIController, :process
    get "/test", TestAPIController, :process

    resources "/users", UsersController, except: [:new, :edit]
    resources "/servers", ServersController, except: [:new, :edit]
    resources "/channels", ChannelsController, except: [:new, :edit]
    # memberships: use composite keys handled via query params; only create/delete/index
    post "/memberships", MembershipsController, :create
    get "/memberships", MembershipsController, :index
    delete "/memberships", MembershipsController, :delete

    resources "/messages", MessagesController, except: [:new, :edit]
    resources "/posts", PostsController, except: [:new, :edit]
    resources "/storage_items", StorageItemsController, except: [:new, :edit]
    resources "/ai_agents", AiAgentsController, except: [:new, :edit]
    resources "/agent_messages", AgentMessagesController, except: [:new, :edit]
  end
end
