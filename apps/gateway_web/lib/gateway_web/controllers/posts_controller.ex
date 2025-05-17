defmodule GatewayWeb.PostsController do
  use GatewayWeb, :controller
  alias Core.Content
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    server_id = Map.get(params, "server_id")
    json(conn, Enum.map(Content.list_posts(server_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Content.get_post!(id)))
  end

  def create(conn, params) do
    case Content.create_post(params) do
      {:ok, post} ->
        conn |> put_status(:created) |> json(serialize(post))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    post = Content.get_post!(id)

    case Content.update_post(post, Map.delete(params, "id")) do
      {:ok, post} ->
        json(conn, serialize(post))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Content.get_post!(id)
    {:ok, _} = Content.delete_post(post)
    send_resp(conn, :no_content, "")
  end

  defp serialize(p),
    do: %{
      id: p.id,
      slug: p.slug,
      title: p.title,
      html_content: p.html_content,
      is_public: p.is_public,
      server_id: p.server_id,
      author_id: p.author_id,
      inserted_at: p.inserted_at
    }
end
