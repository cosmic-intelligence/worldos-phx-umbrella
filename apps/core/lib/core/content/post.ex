defmodule Core.Content.Post do
  @moduledoc """
  Represents a blog/news post within a server.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "posts" do
    field :slug, :string
    field :title, :string
    field :html_content, :string
    field :is_public, :boolean, default: true

    belongs_to :server, Core.Servers.Server, type: :binary_id
    belongs_to :author, Core.Accounts.User, type: :binary_id, foreign_key: :author_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:slug, :title, :html_content, :is_public, :server_id, :author_id])
    |> validate_required([:slug, :title, :html_content, :server_id, :author_id])
    |> validate_length(:slug, min: 1, max: 100)
    |> unique_constraint(:slug, name: :posts_server_id_slug_index)
  end
end
