defmodule Core.Messaging do
  @moduledoc """
  Context for handling chat messages.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Messaging.Message

  def list_messages(channel_id \\ nil) do
    query =
      if channel_id, do: from(m in Message, where: m.channel_id == ^channel_id), else: Message

    Repo.all(query)
  end

  def get_message!(id), do: Repo.get!(Message, id)

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def update_message(%Message{} = msg, attrs) do
    msg
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  def delete_message(%Message{} = msg), do: Repo.delete(msg)

  def change_message(%Message{} = msg, attrs \\ %{}), do: Message.changeset(msg, attrs)
end
