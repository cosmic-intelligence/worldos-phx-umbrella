defmodule GatewayWeb.TestAPIController do
  use GatewayWeb, :controller

  def process(conn, params) do
    # Extract text from params
    text = Map.get(params, "text", "Hello World")

    # Call Core for database transaction
    {:ok, db_result} = Core.TestService.store_request(text)

    # Call AI Bridge for processing
    ai_result = AiBridge.ping(text)

    # Return combined results
    json(conn, %{
      status: "success",
      db_result: db_result,
      ai_result: ai_result
    })
  end
end
