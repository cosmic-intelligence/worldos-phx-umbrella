defmodule Core.Servers do
  @moduledoc """
  Context for Server-related entities (servers, channels, memberships).
  Only minimal CRUD helpers are exposed.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Servers.{Server, Channel, Membership}

  # Server CRUD ----------------------------------------------------------
  def list_servers do
    Repo.all(Server)
  end

  def get_server!(id), do: Repo.get!(Server, id)

  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
  end

  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def delete_server(%Server{} = server), do: Repo.delete(server)

  def change_server(%Server{} = server, attrs \\ %{}), do: Server.changeset(server, attrs)

  # Channel CRUD ---------------------------------------------------------
  def list_channels(server_id \\ nil) do
    query = if server_id, do: from(c in Channel, where: c.server_id == ^server_id), else: Channel
    Repo.all(query)
  end

  def get_channel!(id), do: Repo.get!(Channel, id)

  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  def delete_channel(%Channel{} = channel), do: Repo.delete(channel)

  def change_channel(%Channel{} = channel, attrs \\ %{}), do: Channel.changeset(channel, attrs)

  # Membership CRUD ------------------------------------------------------
  def list_memberships(opts \\ []) do
    query =
      Membership
      |> maybe_filter(:user_id, opts)
      |> maybe_filter(:server_id, opts)

    Repo.all(query)
  end

  defp maybe_filter(query, _field, []), do: query

  defp maybe_filter(query, field, opts) do
    case Keyword.get(opts, field) do
      nil -> query
      val -> from(m in query, where: field(m, ^field) == ^val)
    end
  end

  def get_membership!(user_id, server_id) do
    Repo.get_by!(Membership, user_id: user_id, server_id: server_id)
  end

  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def update_membership(%Membership{} = memb, attrs) do
    memb
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  def delete_membership(%Membership{} = memb), do: Repo.delete(memb)

  def change_membership(%Membership{} = memb, attrs \\ %{}),
    do: Membership.changeset(memb, attrs)
end
