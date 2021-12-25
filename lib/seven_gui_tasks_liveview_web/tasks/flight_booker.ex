defmodule SevenGuiTasksLiveviewWeb.Tasks.FlightBooker do
  @moduledoc false

  use SevenGuiTasksLiveviewWeb, :live_view

  alias SevenGuiTasksLiveviewWeb.Tasks

  @impl true
  def mount(_params, _session, socket) do
    today =
      "EST"
      |> DateTime.now!()
      |> DateTime.to_date()

    initial_date = Enum.join([today.day, today.month, today.year], ".")

    {:ok, assign(socket, type: "one-way", start_date: initial_date, return_date: initial_date)}
  end

  @impl true
  def render(assigns) do
    parsed_start = parse_date(assigns.start_date)
    parsed_end = parse_date(assigns.return_date)

    disable_submit =
      if assigns.type == "return" do
        parsed_start == :error or parsed_end == :error or
          Date.compare(parsed_start, parsed_end) == :gt
      else
        parsed_start == :error
      end

    ~H"""
      <Tasks.frame title="Flight Booker">
        <form class="flight-form" phx-change="update-flight" phx-submit="submit-flight">
          <select name="type">
            <.select_option value="one-way" selected_type={@type} label="One way" />
            <.select_option value="return" selected_type={@type} label="Return" />
          </select>
          <.date_input name="start-date" type={@type} value={@start_date} />
          <.date_input name="return-date" type={@type} value={@return_date} disabled={parsed_end == :error or @type == "one-way"} />
          <button type="submit" disabled={disable_submit}>Book</button>
        </form>
      </Tasks.frame>
    """
  end

  @impl true
  def handle_event("update-flight", form_data, socket) do
    socket =
      socket
      |> assign(type: form_data["type"])
      |> assign(start_date: form_data["start-date"])

    socket =
      if Map.has_key?(form_data, "return-date") do
        assign(socket, return_date: form_data["return-date"])
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("submit-flight", form_data, socket) do
    message =
      get_flight_message(form_data["type"], form_data["start-date"], form_data["return-date"])

    socket = put_flash(socket, :info, message)

    {:noreply, socket}
  end

  defp get_flight_message("one-way", start_date, _return_date),
    do: "You have booked a one-way flight on #{start_date}."

  defp get_flight_message("return", start_date, return_date),
    do: "You have booked a two-way flight from #{start_date} to #{return_date}."

  defp select_option(assigns) do
    ~H"<option value={@value} selected={@selected_type === @value}><%= @label %></option>"
  end

  defp date_input(assigns) do
    disabled? = assigns.name == "return-date" and not return_flight?(assigns.type)
    parsed_date = parse_date(assigns.value)
    assigns = Map.put_new(assigns, :disabled, false)
    class = if not disabled? and parsed_date == :error, do: "invalid-date", else: ""

    ~H"""
      <input
        type="text"
        name={@name}
        disabled={@disabled}
        value={@value}
        class={class}
      />
    """
  end

  defp return_flight?(type), do: type == "return"

  defp parse_date(date) do
    with [day, month, year] <- String.split(date, "."),
         {day, ""} <- Integer.parse(day),
         {month, ""} <- Integer.parse(month),
         {year, ""} <- Integer.parse(year),
         {:ok, date} <- Date.new(year, month, day) do
      date
    else
      _ -> :error
    end
  end
end
