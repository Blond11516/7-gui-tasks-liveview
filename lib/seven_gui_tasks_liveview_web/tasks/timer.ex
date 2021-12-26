defmodule SevenGuiTasksLiveviewWeb.Tasks.Timer do
  @moduledoc false

  use SevenGuiTasksLiveviewWeb, :live_view

  alias SevenGuiTasksLiveviewWeb.Tasks

  @impl true
  def mount(_params, _session, socket) do
    initial_max = 5

    if connected?(socket) do
      Timer.start_link(initial_max * 1000)
    end

    {:ok, assign(socket, max: initial_max, elapsed: 0)}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <Tasks.frame title="Timer">
        <form id="timer-form" class="timer-form" phx-change="update-max" phx-submit="reset">
          <label>
            Elapsed time:
            <progress max={@max} value={@elapsed} />
          </label>
          <span><%= @elapsed %></span>
          <label>
            Duration:
            <input type="range" min="0" max="100" value={@max} name="max" />
          </label>
          <button type="submit">Reset</button>
        </form>
      </Tasks.frame>
    """
  end

  @impl true
  def handle_event("update-max", %{"max" => max}, socket) do
    max = String.to_integer(max)
    Timer.set_max(max * 1000)
    {:noreply, assign(socket, max: max)}
  end

  def handle_event("reset", _, socket) do
    Timer.reset()
    {:noreply, assign(socket, elapsed: 0)}
  end

  @impl true
  def handle_info({:time, time}, socket) do
    {:noreply, assign(socket, elapsed: time / 1000)}
  end
end

defmodule Timer do
  @moduledoc false

  use GenServer

  def start_link(initial_max) do
    GenServer.start_link(__MODULE__, {self(), initial_max}, name: name())
  end

  def reset() do
    GenServer.cast(name(), :reset)
  end

  def set_max(max) do
    GenServer.cast(name(), {:set_max, max})
  end

  @impl true
  def init({parent_pid, initial_max}) do
    state =
      %{max: initial_max, parent_pid: parent_pid}
      |> reset_timer()

    schedule_tick(state.ref)

    {:ok, state}
  end

  @impl true
  def handle_cast(:reset, state) do
    {:noreply, reset_timer(state)}
  end

  def handle_cast({:set_max, max}, state) do
    state =
      if max > state.max and state.elapsed >= state.max do
        reset_timer(state, state.elapsed)
      else
        state
      end

    {:noreply, %{state | max: max}}
  end

  @impl true
  def handle_info({:tick, tick_ref}, %{ref: ref} = state) do
    if tick_ref == ref do
      tick(state)
    else
      {:noreply, state}
    end
  end

  defp tick(state) do
    now = now()
    elapsed = now - state.started_at

    elpased = min(elapsed, state.max)

    if elpased != state.max do
      schedule_tick(state.ref)
    end

    send(state.parent_pid, {:time, elapsed})

    {:noreply, %{state | elapsed: elapsed}}
  end

  defp schedule_tick(ref), do: Process.send_after(self(), {:tick, ref}, 100)

  defp reset_timer(state, start_offset \\ 0) do
    state =
      Map.merge(state, %{started_at: now() - start_offset, elapsed: start_offset, ref: make_ref()})

    schedule_tick(state.ref)
    state
  end

  defp now, do: System.monotonic_time(:millisecond)

  defp name, do: __MODULE__
end
