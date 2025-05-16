defmodule Core.TestService do
  require Logger
  alias Core.Repo

  @doc """
  Stores a request in the database (simulation)

  In a real app, this would create a schema and insert it into the database
  """
  def store_request(text) do
    # Simulate database transaction
    Logger.info("Storing request in database: #{text}")

    # In a real app, you would do something like:
    # %RequestLog{text: text, timestamp: DateTime.utc_now()}
    # |> Repo.insert()

    # For now, just simulate a successful DB operation
    {:ok, %{id: Ecto.UUID.generate(), text: text, timestamp: DateTime.utc_now()}}
  end
end
