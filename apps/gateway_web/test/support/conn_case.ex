defmodule GatewayWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that need to set up a connection (`Plug.Conn`).

  It:
    * imports `Phoenix.ConnTest` helpers
    * starts an owner process for the SQL sandbox (Core.Repo)
    * builds a fresh connection with `accept: application/json`
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use Phoenix.ConnTest
      import Plug.Conn

      @endpoint GatewayWeb.Endpoint
    end
  end

  setup tags do
    pid =
      Ecto.Adapters.SQL.Sandbox.start_owner!(Core.Repo, shared: not tags[:async])

    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    conn = Phoenix.ConnTest.build_conn() |> Plug.Conn.put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end
end
