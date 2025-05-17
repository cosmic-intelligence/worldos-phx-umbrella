# cli_test_runner.exs

defmodule CliTestRunner do
  # Default, can be overridden if your app runs elsewhere
  @base_url "http://localhost:4000/api"

  # --- In-memory Store for IDs using Agent ---
  # This store will keep track of IDs of created entities (users, servers, etc.)
  # to allow chaining operations (e.g., create a user, then use that user's ID to create a server).

  defp start_store do
    Agent.start_link(
      fn -> %{users: [], servers: [], channels: [], posts: [], agents: [], items: []} end,
      name: :store
    )
  end

  defp add_to_store(key, id) do
    Agent.update(:store, fn state ->
      # Prepend to keep the latest ID at the head for easy access
      Map.update(state, key, [id], fn existing_ids -> [id | existing_ids] end)
    end)
  end

  defp get_latest_from_store(key) do
    Agent.get(:store, fn state -> List.first(Map.get(state, key, [])) end)
  end

  defp get_random_from_store(key) do
    Agent.get(:store, fn state ->
      ids = Map.get(state, key, [])
      if Enum.empty?(ids), do: nil, else: Enum.random(ids)
    end)
  end

  # --- HTTP Client Helpers ---
  defp json_headers, do: [{"Content-Type", "application/json"}, {"Accept", "application/json"}]

  defp request(method, path_segment, body \\ nil, query_params \\ %{}) do
    url = @base_url <> path_segment
    # Append query parameters if any
    url_with_query =
      if Enum.empty?(query_params), do: url, else: url <> "?" <> URI.encode_query(query_params)

    IO.puts("--> #{method |> Atom.to_string() |> String.upcase()} #{url_with_query}")
    if body, do: IO.puts("    Body: #{Jason.encode!(body)}")

    # Basic SSL options, adjust if needed for specific HTTPS configurations
    options =
      if String.starts_with?(@base_url, "https"),
        do: [ssl: [{:versions, [:"tlsv1.2", :"tlsv1.3"]}]],
        else: []

    response =
      case method do
        :get ->
          HTTPoison.get(url_with_query, json_headers(), options)

        :post ->
          HTTPoison.post(url_with_query, Jason.encode!(body), json_headers(), options)

        :put ->
          HTTPoison.put(url_with_query, Jason.encode!(body), json_headers(), options)

        :patch ->
          HTTPoison.patch(url_with_query, Jason.encode!(body), json_headers(), options)

        # Standard DELETE
        :delete ->
          HTTPoison.delete(url_with_query, json_headers(), options)
      end

    handle_response(response)
  end

  # Specialized delete for memberships which seems to use query parameters for identification
  defp delete_request_with_params(path_segment, params_for_delete_query) do
    url = @base_url <> path_segment
    url_with_query = url <> "?" <> URI.encode_query(params_for_delete_query)

    IO.puts("--> DELETE #{url_with_query}")

    options =
      if String.starts_with?(@base_url, "https"),
        do: [ssl: [{:versions, [:"tlsv1.2", :"tlsv1.3"]}]],
        else: []

    response = HTTPoison.delete(url_with_query, json_headers(), options)

    handle_response(response)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: status_code, body: resp_body}}) do
    IO.puts("<-- #{status_code}")

    parsed_body =
      cond do
        # Handle empty body for 204 No Content etc.
        resp_body == "" or resp_body == nil ->
          %{}

        is_binary(resp_body) ->
          try do
            Jason.decode!(resp_body)
          rescue
            Jason.DecodeError ->
              IO.puts("    Raw Non-JSON Body: #{resp_body}")
              %{"raw_body" => resp_body, "error" => "Failed to decode JSON response"}
          end

        # If already parsed by HTTPoison middleware (less common for basic usage)
        true ->
          resp_body
      end

    IO.inspect(parsed_body, pretty: true, label: "    Response Body")
    {status_code, parsed_body}
  end

  defp handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    IO.puts("<-- HTTP Error: #{inspect(reason)}")
    {:error, reason}
  end

  # --- Data Generators ---
  defp random_string(length) do
    # Adjust byte count for Base64
    :crypto.strong_rand_bytes(div(length * 3, 4) + 1)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  defp random_username, do: "user_" <> random_string(6)
  defp random_email, do: random_string(8) <> "@example.com"
  defp random_password, do: "pass_" <> random_string(10)

  # --- API Endpoint Functions ---

  # Users
  def create_user(attrs \\ %{}) do
    default_attrs = %{
      username: random_username(),
      email: random_email(),
      password: random_password()
    }

    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/users", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:users, body["id"])
    {status, body}
  end

  def list_users, do: request(:get, "/users")

  def create_n_users(n) when is_integer(n) and n > 0 do
    IO.puts("Attempting to create #{n} users...")

    Enum.each(1..n, fn i ->
      IO.puts("Creating user #{i}/#{n}...")
      {status, body} = create_user()
      unless status == 201, do: IO.puts("Failed to create user #{i}: #{inspect(body)}")
    end)

    IO.puts("#{n} user creation attempts finished. Check API logs and store state.")
  end

  # Servers
  defp ensure_user_id do
    get_random_from_store(:users) ||
      case create_user() do
        {201, %{"id" => user_id}} ->
          user_id

        _ ->
          IO.puts("Failed to create a prerequisite user.")
          nil
      end
  end

  def create_server(attrs \\ %{}) do
    owner_id = Map.get(attrs, :owner_id) || ensure_user_id()

    unless owner_id do
      IO.puts("Error: Cannot create server without an owner_id. User creation/retrieval failed.")
      {:error, "Missing owner_id"}
    end

    default_attrs = %{name: "Server_" <> random_string(5), is_public: true, owner_id: owner_id}
    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/servers", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:servers, body["id"])
    {status, body}
  end

  def list_servers, do: request(:get, "/servers")

  def get_server(id \\ nil) do
    server_id = id || get_latest_from_store(:servers)

    if server_id,
      do: request(:get, "/servers/#{server_id}"),
      else: IO.puts("No server ID for get. Create one or provide ID.")
  end

  # Attrs first for easier piping if desired
  def update_server(attrs, id \\ nil) do
    server_id = id || get_latest_from_store(:servers)

    if server_id,
      do: request(:patch, "/servers/#{server_id}", attrs),
      else: IO.puts("No server ID for update.")
  end

  def delete_server(id \\ nil) do
    server_id = id || get_latest_from_store(:servers)

    if server_id,
      do: request(:delete, "/servers/#{server_id}"),
      else: IO.puts("No server ID for delete.")
  end

  # Channels
  defp ensure_server_id do
    get_random_from_store(:servers) ||
      case create_server() do
        {201, %{"id" => server_id}} ->
          server_id

        _ ->
          IO.puts("Failed to create a prerequisite server.")
          nil
      end
  end

  def create_channel(attrs \\ %{}) do
    server_id = Map.get(attrs, :server_id) || ensure_server_id()

    unless server_id do
      IO.puts("Error: Cannot create channel without a server_id.")
      {:error, "Missing server_id"}
    end

    default_attrs = %{
      name: "Channel_" <> random_string(5),
      position: 0,
      is_private: false,
      server_id: server_id
    }

    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/channels", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:channels, body["id"])
    {status, body}
  end

  def list_channels(server_id_param \\ nil) do
    s_id = server_id_param || get_latest_from_store(:servers)

    if s_id,
      do: request(:get, "/channels", %{server_id: s_id}),
      else: IO.puts("No server_id for listing channels. Create a server or provide server_id.")
  end

  # GET /channels/:id, PATCH /channels/:id, DELETE /channels/:id can be added similar to servers

  # Memberships
  def create_membership(user_id_param \\ nil, server_id_param \\ nil, role \\ 1) do
    u_id = user_id_param || ensure_user_id()
    s_id = server_id_param || ensure_server_id()

    unless u_id && s_id do
      IO.puts("Error: Missing user_id or server_id for membership creation.")
      {:error, "Missing user_id or server_id"}
    end

    attrs = %{user_id: u_id, server_id: s_id, role: role}
    # Membership creation usually doesn't return an ID to store simply.
    request(:post, "/memberships", attrs)
  end

  def list_memberships(params \\ %{}) do
    default_server_id = get_latest_from_store(:servers)

    final_params =
      if Enum.empty?(params) && default_server_id,
        do: %{server_id: default_server_id},
        else: params

    cond do
      Map.has_key?(final_params, :server_id) ->
        request(:get, "/memberships", final_params)

      Map.has_key?(final_params, :user_id) ->
        request(:get, "/memberships", final_params)

      Enum.empty?(final_params) ->
        IO.puts(
          "Warning: Listing all memberships. Consider filtering by 'server_id' or 'user_id'."
        )

        request(:get, "/memberships", final_params)

      true ->
        IO.puts("Invalid params for list_memberships. Use %{server_id: id} or %{user_id: id}.")
    end
  end

  def delete_membership(user_id_param \\ nil, server_id_param \\ nil) do
    # Get any user if not specified
    u_id = user_id_param || get_random_from_store(:users)
    # Get any server
    s_id = server_id_param || get_random_from_store(:servers)

    unless u_id && s_id do
      IO.puts(
        "Error: Missing user_id or server_id to delete membership. Ensure users and servers exist in store or provide IDs."
      )

      {:error, "Missing user_id or server_id for delete_membership"}
    end

    delete_request_with_params("/memberships", %{user_id: u_id, server_id: s_id})
  end

  # Messages
  defp ensure_channel_id do
    get_random_from_store(:channels) ||
      case create_channel() do
        {201, %{"id" => channel_id}} ->
          channel_id

        _ ->
          IO.puts("Failed to create a prerequisite channel.")
          nil
      end
  end

  def create_message(content_param \\ nil, author_id_param \\ nil, channel_id_param \\ nil) do
    a_id = author_id_param || ensure_user_id()
    c_id = channel_id_param || ensure_channel_id()

    unless a_id && c_id do
      IO.puts("Error: Missing author_id or channel_id for message creation.")
      {:error, "Missing author_id or channel_id"}
    end

    final_content = content_param || "Test Message: " <> random_string(20)
    attrs = %{content: final_content, author_id: a_id, channel_id: c_id}
    # Not storing message IDs by default
    request(:post, "/messages", attrs)
  end

  def list_messages(channel_id_param \\ nil) do
    c_id = channel_id_param || get_latest_from_store(:channels)

    if c_id,
      do: request(:get, "/messages", %{channel_id: c_id}),
      else: IO.puts("No channel_id for listing messages. Create a channel or provide ID.")
  end

  # Posts
  def create_post(attrs \\ %{}) do
    author_id = Map.get(attrs, :author_id) || ensure_user_id()
    server_id = Map.get(attrs, :server_id) || ensure_server_id()

    unless author_id && server_id do
      IO.puts("Error: Missing author_id or server_id for post creation.")
      {:error, "Missing IDs for post"}
    end

    default_attrs = %{
      slug: "post-" <> random_string(8),
      title: "Post Title " <> random_string(10),
      html_content: "<p>Some random post content " <> random_string(30) <> "</p>",
      is_public: true,
      author_id: author_id,
      server_id: server_id
    }

    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/posts", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:posts, body["id"])
    {status, body}
  end

  def list_posts(server_id_param \\ nil) do
    s_id = server_id_param || get_latest_from_store(:servers)

    if s_id,
      do: request(:get, "/posts", %{server_id: s_id}),
      else: IO.puts("No server_id for listing posts.")
  end

  # AI Agents
  def create_ai_agent(attrs \\ %{}) do
    creator_id = Map.get(attrs, :creator_id) || ensure_user_id()
    server_id = Map.get(attrs, :server_id) || ensure_server_id()

    unless creator_id && server_id do
      IO.puts("Error: Missing creator_id or server_id for AI agent.")
      {:error, "Missing IDs for AI agent"}
    end

    default_attrs = %{
      name: "Agent_" <> random_string(5),
      config: %{
        "model" => "gpt-3.5-turbo",
        "temperature" => 0.7,
        "system_prompt" => "Test Bot: " <> random_string(10)
      },
      creator_id: creator_id,
      server_id: server_id
    }

    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/ai_agents", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:agents, body["id"])
    {status, body}
  end

  def list_ai_agents(server_id_param \\ nil) do
    s_id = server_id_param || get_latest_from_store(:servers)

    if s_id,
      do: request(:get, "/ai_agents", %{server_id: s_id}),
      else: IO.puts("No server_id for listing AI agents.")
  end

  # Storage Items
  def create_storage_item(attrs \\ %{}) do
    uploader_id = Map.get(attrs, :uploader_id) || ensure_user_id()
    server_id = Map.get(attrs, :server_id) || ensure_server_id()

    unless uploader_id && server_id do
      IO.puts("Error: Missing uploader_id or server_id for storage item.")
      {:error, "Missing IDs for storage item"}
    end

    default_attrs = %{
      path: "/uploads/cli_item_" <> random_string(8) <> ".dat",
      mime_type: "application/octet-stream",
      byte_size: Enum.random(1000..100_000),
      uploader_id: uploader_id,
      server_id: server_id
    }

    final_attrs = Map.merge(default_attrs, attrs)
    {status, body} = request(:post, "/storage_items", final_attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:items, body["id"])
    {status, body}
  end

  def list_storage_items(server_id_param \\ nil) do
    s_id = server_id_param || get_latest_from_store(:servers)

    if s_id,
      do: request(:get, "/storage_items", %{server_id: s_id}),
      else: IO.puts("No server_id for listing storage items.")
  end

  # --- CLI Main Function & Argument Parser ---
  def main(args) do
    # Ensure HTTPoison and Jason are started (typically handled by adding to :extra_applications in mix.exs)
    # For standalone script, ensure they are available.
    Application.ensure_all_started(:httpoison)
    # Jason might not need explicit start, but good practice.
    Application.ensure_all_started(:jason)

    # Initialize the in-memory store for this run
    start_store()
    parse_args(args)
  end

  defp parse_args([]), do: print_help()
  defp parse_args(["help" | _]), do: print_help()

  defp parse_args(["create_users", count_str | _]) do
    case Integer.parse(count_str) do
      {count, ""} when count > 0 -> create_n_users(count)
      _ -> IO.puts("Invalid count: '#{count_str}'. Usage: create_users <positive_integer>")
    end
  end

  defp parse_args(["list_users" | _]), do: list_users()

  defp parse_args(["create_server" | _]), do: create_server()
  defp parse_args(["list_servers" | _]), do: list_servers()
  defp parse_args(["get_server" | [id | _]]), do: get_server(id)
  defp parse_args(["get_server" | _]), do: get_server()
  defp parse_args(["delete_server" | [id | _]]), do: delete_server(id)
  defp parse_args(["delete_server" | _]), do: delete_server()

  defp parse_args(["create_channel" | _]), do: create_channel()
  defp parse_args(["list_channels" | [server_id | _]]), do: list_channels(server_id)
  defp parse_args(["list_channels" | _]), do: list_channels()

  defp parse_args(["create_membership" | _]), do: create_membership()
  # e.g., server_id=some_id or user_id=some_id
  defp parse_args(["list_memberships" | [filter_str | _]]) do
    case String.split(filter_str, "=") do
      [key, value] when key in ["server_id", "user_id"] ->
        list_memberships(%{String.to_atom(key) => value})

      # Default or invalid filter
      _ ->
        list_memberships()
    end
  end

  defp parse_args(["list_memberships" | _]), do: list_memberships()
  # Uses random from store
  defp parse_args(["delete_membership" | _]), do: delete_membership()

  defp parse_args(["create_message" | _]), do: create_message()
  defp parse_args(["list_messages" | [channel_id | _]]), do: list_messages(channel_id)
  defp parse_args(["list_messages" | _]), do: list_messages()

  defp parse_args(["create_post" | _]), do: create_post()
  defp parse_args(["list_posts" | [server_id | _]]), do: list_posts(server_id)
  defp parse_args(["list_posts" | _]), do: list_posts()

  defp parse_args(["create_ai_agent" | _]), do: create_ai_agent()
  defp parse_args(["list_ai_agents" | [server_id | _]]), do: list_ai_agents(server_id)
  defp parse_args(["list_ai_agents" | _]), do: list_ai_agents()

  defp parse_args(["create_storage_item" | _]), do: create_storage_item()
  defp parse_args(["list_storage_items" | [server_id | _]]), do: list_storage_items(server_id)
  defp parse_args(["list_storage_items" | _]), do: list_storage_items()

  defp parse_args(["show_store" | _]) do
    IO.puts("Current in-memory store state:")
    IO.inspect(Agent.get(:store, & &1), pretty: true)
  end

  defp parse_args(["test_all_creates" | _]) do
    IO.puts("\n--- Testing all CREATE operations sequentially ---")
    {s_user, b_user} = create_user(%{username: "testall_user"})
    user_id = if s_user == 201 && Map.has_key?(b_user, "id"), do: b_user["id"]

    if user_id do
      IO.puts("\n--- User created, proceeding to server ---")
      {s_server, b_server} = create_server(%{owner_id: user_id, name: "TestAll_Server"})
      server_id = if s_server == 201 && Map.has_key?(b_server, "id"), do: b_server["id"]

      if server_id do
        IO.puts("\n--- Server created, proceeding to channel, membership, etc. ---")
        create_channel(%{server_id: server_id, name: "TestAll_General_Channel"})

        {s_chan_msg, b_chan_msg} =
          create_channel(%{server_id: server_id, name: "TestAll_Message_Channel"})

        channel_for_msg_id =
          if s_chan_msg == 201 && Map.has_key?(b_chan_msg, "id"), do: b_chan_msg["id"]

        create_membership(user_id, server_id)

        if channel_for_msg_id do
          create_message("Hello from TestAll run!", user_id, channel_for_msg_id)
        else
          IO.puts("Skipped message creation as TestAll_Message_Channel creation failed.")
        end

        create_post(%{author_id: user_id, server_id: server_id, title: "TestAll Demo Post"})
        create_ai_agent(%{creator_id: user_id, server_id: server_id, name: "TestAll_Agent"})

        create_storage_item(%{
          uploader_id: user_id,
          server_id: server_id,
          path: "/testall/item.file"
        })
      else
        IO.puts("Skipping server-dependent creates as TestAll_Server creation failed.")
      end
    else
      IO.puts("Skipping all dependent creates as initial TestAll_User creation failed.")
    end

    IO.puts("\n--- Finished TestAll Creates Attempt ---")
    parse_args(["show_store"])
  end

  defp parse_args(["create_unique_user" | _]) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    username = "unique_user_#{timestamp}"

    IO.puts("\n--- Creating unique user with username: #{username} ---")

    attrs = %{
      username: username,
      email: "#{username}@example.com",
      password: "pass_#{random_string(10)}"
    }

    {status, body} = request(:post, "/users", attrs)
    if status == 201 && Map.has_key?(body, "id"), do: add_to_store(:users, body["id"])

    IO.puts("\n--- Showing in-memory store state ---")
    IO.inspect(Agent.get(:store, & &1), pretty: true)

    {status, body}
  end

  defp parse_args(unknown_command) do
    IO.puts("Unknown command or arguments: #{inspect(unknown_command)}")
    print_help()
  end

  defp print_help do
    IO.puts("""
    CLI Test Runner for Your Elixir API

    Usage: mix run path/to/cli_test_runner.exs <command> [args]

    Commands:
      help                                - Shows this help message.
      show_store                          - Displays the current in-memory store of created IDs.

    User Endpoints:
      create_users <count>                - Creates <count> random users.
      list_users                          - Lists users from the API.

    Server Endpoints:
      create_server                       - Creates a server (uses/creates a user as owner).
      list_servers                        - Lists servers from the API.
      get_server [id]                     - Gets a server by id (or latest from store).
      delete_server [id]                  - Deletes a server by id (or latest from store).
      # update_server {json_attrs} [id]   - (Example, implement if needed)

    Channel Endpoints:
      create_channel                      - Creates a channel (uses/creates a server).
      list_channels [server_id]           - Lists channels for a server_id (or latest server from store).

    Membership Endpoints:
      create_membership                   - Creates a membership (uses/creates user & server).
      list_memberships [filter]           - Lists memberships (e.g., 'server_id=X' or 'user_id=Y').
      delete_membership                   - Deletes a membership (uses random user/server from store).

    Message Endpoints:
      create_message                      - Creates a message (uses/creates user & channel).
      list_messages [channel_id]          - Lists messages for a channel_id (or latest channel).

    Post Endpoints:
      create_post                         - Creates a post (uses/creates user & server).
      list_posts [server_id]              - Lists posts for a server_id (or latest server).

    AI Agent Endpoints:
      create_ai_agent                     - Creates an AI agent (uses/creates user & server).
      list_ai_agents [server_id]          - Lists AI agents for a server_id (or latest server).

    Storage Item Endpoints:
      create_storage_item                 - Creates a storage item (uses/creates user & server).
      list_storage_items [server_id]      - Lists storage items for server_id (or latest server).

    Utility:
      test_all_creates                    - Runs a sequence of create operations for all primary resources.
                                            Useful for quick data population and basic API health check.
    """)
  end
end

# Script Entry Point: This line executes the main function with command line arguments.
CliTestRunner.main(System.argv())
