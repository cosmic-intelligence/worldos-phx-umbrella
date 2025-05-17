defmodule Core.Messaging.Message do
  @moduledoc """
  Represents a user-authored message in a channel.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    field :content, :string

    belongs_to :channel, Core.Servers.Channel, type: :binary_id
    belongs_to :author, Core.Accounts.User, type: :binary_id, foreign_key: :author_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :channel_id, :author_id])
    |> validate_required([:content, :channel_id, :author_id])
  end
end
