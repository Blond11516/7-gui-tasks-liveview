defmodule SevenGuiTasksLiveviewWeb.Tasks.Temperature do
  @moduledoc false

  use SevenGuiTasksLiveviewWeb, :live_view

  alias SevenGuiTasksLiveviewWeb.Tasks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, celcius: 5, farenheit: 41)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <Tasks.frame title="Temperature converter">
        <form class="temperature-wrapper" phx-change="change_temperature" id="temperature-form">
          <.temperature_input scale={:celcius} value={@celcius} />
          <span>=</span>
          <.temperature_input scale={:farenheit} value={@farenheit} />
        </form>
      </Tasks.frame>
    """
  end

  @impl true
  def handle_event(
        "change_temperature",
        form_state,
        socket
      ) do
    [target_scale] = form_state["_target"]
    new_temp = form_state[target_scale]
    target_scale = String.to_existing_atom(target_scale)
    {:noreply, update_temperatures(socket, target_scale, new_temp)}
  end

  defp temperature_input(assigns) do
    ~H"""
    <label>
      <input type="number" name={@scale} class="temperature-input" value={@value} />
      <%= @scale %>
    </label>
    """
  end

  defp update_temperatures(socket, updated_scale, new_value) do
    conversion = %{
      celcius: %{
        other_scale: :farenheit,
        converter: &celcius_to_farenheit/1
      },
      farenheit: %{
        other_scale: :celcius,
        converter: &farenheit_to_celcius/1
      }
    }

    conversion = conversion[updated_scale]

    case Float.parse(new_value) do
      {new_value, ""} ->
        other_new = conversion.converter.(new_value)
        assign(socket, [{conversion.other_scale, other_new}, {updated_scale, new_value}])

      _ ->
        socket
    end
  end

  defp celcius_to_farenheit(c), do: c * (9 / 5) + 32
  defp farenheit_to_celcius(f), do: (f - 32) * (5 / 9)
end
