defmodule SevenGuiTasksLiveviewWeb.PageController do
  use SevenGuiTasksLiveviewWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
