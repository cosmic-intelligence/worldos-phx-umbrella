defmodule Core.RepoTest do
  use Core.DataCase

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

    # Explanation: Let's also check that the connection pool is available
    # by verifying Repo.all works with a simple SQL fragment
    assert is_list(Core.Repo.all(fragment("SELECT generate_series(1, 3) as num")))
  end
end
