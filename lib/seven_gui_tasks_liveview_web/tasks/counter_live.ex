defmodule SevenGuiTasksLiveviewWeb.Tasks.Counter do
  @moduledoc false

  use SevenGuiTasksLiveviewWeb, :live_view

  alias SevenGuiTasksLiveviewWeb.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <Tasks.frame title="Counter">
        <span><%= @count %></span>
        <button type="button" phx-click="count">Count</button>
      </Tasks.frame>
    """
  end

  @impl true
  def handle_event("count", _, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end
end
