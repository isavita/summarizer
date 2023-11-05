defmodule SummarizerWeb.Router do
  use SummarizerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  get "/health", SummarizerWeb.HealthController, :index

  scope "/", SummarizerWeb do
    get "/", ReadmeController, :index
    post "/create", ReadmeController, :create

    match :*, "/*path", PageController, :not_found
  end

  scope "/api", SummarizerWeb do
    pipe_through :api
  end

  if Application.compile_env(:summarizer, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
    end
  end
end
