defmodule SevenGuiTasksLiveviewWeb.Tasks do
  @moduledoc false

  use Phoenix.Component

  def frame(assigns) do
    assigns = assign_new(assigns, :width, fn -> "fit-content" end)

    ~H"""
      <div class="frame" style={"width: #{get_width(@width)};"}>
        <div class="frame-title">
          <%= @title %>
        </div>
        <div class="frame-body">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    """
  end

  defp get_width(width) when is_integer(width), do: "#{width}px"
  defp get_width(width) when is_binary(width), do: width
end
