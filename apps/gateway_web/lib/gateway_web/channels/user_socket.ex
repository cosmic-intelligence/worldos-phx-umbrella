defmodule GatewayWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel("channel:*", GatewayWeb.MessageChannel)
  channel("server:*", GatewayWeb.ServerChannel)

  @impl true
  def connect(_params, socket, connect_info) do
    # connect_info will contain :session, which is a map of the session data
    # The session cookie itself is handled by Phoenix based on endpoint configuration
    case get_session_user_id(connect_info) do
      {:ok, user_id} ->
        Logger.info("User #{user_id} connected to socket.")
        # Assign user_id to the socket state for use in channels
        socket = assign(socket, :user_id, user_id)
        {:ok, socket}

      :error ->
        Logger.warning("Socket connection rejected - no valid session or user_id found.")
        :error
    end
  end

  # Helper to extract user_id from session in connect_info
  # This assumes your session key for user ID is :user_id
  defp get_session_user_id(connect_info) do
    # The session is typically available under the :session key in connect_info
    # if :session was added to connect_info in endpoint.ex
    session = Map.get(connect_info, :session)

    # If your session plug uses a wrapper (like Guardian does sometimes),
    # you might need to inspect `connect_info` more deeply or use a helper.
    # For standard Plug.Session, the session data should be directly accessible.

    if session do
      # Session keys are often strings
      case Map.get(session, "user_id") do
        nil ->
          Logger.debug("user_id not found in session: #{inspect(session)}")
          :error

        user_id ->
          {:ok, user_id}
      end
    else
      Logger.debug("No session found in connect_info.")
      :error
    end
  end

  @impl true
  # Make socket ID unique per user
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
