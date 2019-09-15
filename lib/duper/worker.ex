defmodule Duper.Worker do

  use GenServer, restart: :transient

  def start_link(_) do
    GenServer.start_link __MODULE__, :no_args
  end

  def init(:no_args) do
    Process.send_after self(), :process_one_file, 0
    {:ok, nil}
  end

  def handle_info(:process_one_file, _) do
    Duper.PathFinder.next_path()
    |> process_path()
  end

  defp process_path(nil) do
    Duper.Gatherer.worker_done()
    {:stop, :normal, nil}
  end
  defp process_path(path) do
    Duper.Gatherer.add_result path, hash_of_file_at(path)
    send(self(), :process_one_file)
    {:noreply, nil}
  end

  defp hash_of_file_at(path) do
    block_size = 1024 * 1024
    File.stream!(path, [], block_size)
    |> Enum.reduce(:crypto.hash_init(:md5),
                   fn block, hash -> :crypto.hash_update(hash, block) end)
    |> :crypto.hash_final()
  end

end
