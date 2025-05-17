defmodule Core.Storage.StorageItem do
  @moduledoc """
  Represents a file uploaded to a server.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "storage_items" do
    field :path, :string
    field :mime_type, :string
    field :byte_size, :integer

    belongs_to :server, Core.Servers.Server, type: :binary_id
    belongs_to :uploader, Core.Accounts.User, type: :binary_id, foreign_key: :uploader_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:path, :mime_type, :byte_size, :server_id, :uploader_id])
    |> validate_required([:path, :mime_type, :byte_size, :server_id, :uploader_id])
  end
end
