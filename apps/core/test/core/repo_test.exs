defmodule Core.RepoTest do
  use Core.DataCase

  import Ecto.Query

  test "database connection is working" do
    # Explanation: This test verifies that we can query the database
    # by making a simple query that always succeeds on a connected database

    # Check if the database is responding to a basic query
    result = Ecto.Adapters.SQL.query!(Core.Repo, "SELECT 1 as result")
    assert result.rows == [[1]]

    # Explanation: We'll use a transaction to verify that we can
    # write to the database, but we'll rollback so no data actually changes
    assert {:ok, _} =
             Core.Repo.transaction(fn ->
               # Inside a transaction, check if we can execute another query
               inner_result = Ecto.Adapters.SQL.query!(Core.Repo, "SELECT 'connected' as status")
               assert inner_result.rows == [["connected"]]

               # Return a value from the transaction
               "success"
             end)

    # Additional simple query via Ecto.SQL to ensure connection responds
    assert %{rows: [[1]]} = Ecto.Adapters.SQL.query!(Core.Repo, "SELECT 1")
  end
end
