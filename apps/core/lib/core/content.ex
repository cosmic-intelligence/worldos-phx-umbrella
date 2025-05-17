defmodule Core.Content do
  @moduledoc """
  Context for blog/news posts.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Content.Post

  def list_posts(server_id \\ nil) do
    query = if server_id, do: from(p in Post, where: p.server_id == ^server_id), else: Post
    Repo.all(query)
  end

  def get_post!(id), do: Repo.get!(Post, id)

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post), do: Repo.delete(post)

  def change_post(%Post{} = post, attrs \\ %{}), do: Post.changeset(post, attrs)
end
