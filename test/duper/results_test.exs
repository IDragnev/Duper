defmodule Duper.ResultsTest do

  use ExUnit.Case
  alias Duper.Results

  test "adding entries to the results" do
    1..6
    |> Enum.map(&"path#{to_string(&1)}")
    |> Enum.zip([123, 456, 123, 789, 456, 999])
    |> Enum.each(&Results.add_hash_for/1)

    duplicates = Results.find_duplicates()

    assert length(duplicates) == 2
    assert ~w{path3 path1} in duplicates
    assert ~w{path5 path2} in duplicates
  end

end
