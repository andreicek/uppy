defmodule Uppy.Scheduler do
  use GenServer

  def start_link([interval, fun]) do
    GenServer.start_link(__MODULE__, %{interval: interval, fun: fun}, name: __MODULE__)
  end

  @impl true
  def init(scheduled_job) do
    {:ok, scheduled_job, {:continue, :schedule_next_run}}
  end

  @impl true
  def handle_continue(:schedule_next_run, %{interval: interval} = scheduled_job) do
    Process.send_after(self(), :perform_cron_work, interval)

    {:noreply, scheduled_job}
  end

  @impl true
  def handle_info(:perform_cron_work, %{fun: [module, method]} = scheduled_job) do
    apply(module, method, [])

    {:noreply, scheduled_job, {:continue, :schedule_next_run}}
  end
end
