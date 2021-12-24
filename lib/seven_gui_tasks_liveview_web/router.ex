defmodule SevenGuiTasksLiveviewWeb.Router do
  use SevenGuiTasksLiveviewWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SevenGuiTasksLiveviewWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", SevenGuiTasksLiveviewWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
