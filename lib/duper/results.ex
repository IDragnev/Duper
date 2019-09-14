defmodule Duper.Results do

  use GenServer

  @me __MODULE__

  #API
  def start_link(_) do
    GenServer.start_link __MODULE__, :no_args, name: @me
  end

  def add_hash_for({path, hash}) do
    GenServer.cast @me, {:add, path, hash}
  end

  def find_duplicates do
    GenServer.call @me, :find_duplicates
  end

  #Server
  def init(:no_args) do
    {:ok, %{}}
  end

  def handle_cast({:add, path, hash}, results) do
    updated_results =
      Map.update(results,
                 hash,
                 [path],
                 fn existing -> [path | existing] end)
    {:noreply, updated_results}
  end

  def handle_call(:find_duplicates, _from, results) do
    response = hashes_with_several_paths(results)
    {:reply, response, results}
  end

  defp hashes_with_several_paths(results) do
    results
    |> Enum.filter(fn {_, paths} -> length(paths) > 1 end)
    |> Enum.map(&elem(&1, 1))
  end

end
