defmodule GatewayWeb.StorageItemsController do
  use GatewayWeb, :controller
  alias Core.Storage
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    server_id = Map.get(params, "server_id")
    json(conn, Enum.map(Storage.list_storage_items(server_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Storage.get_storage_item!(id)))
  end

  def create(conn, params) do
    case Storage.create_storage_item(params) do
      {:ok, item} ->
        conn |> put_status(:created) |> json(serialize(item))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    item = Storage.get_storage_item!(id)

    case Storage.update_storage_item(item, Map.delete(params, "id")) do
      {:ok, item} ->
        json(conn, serialize(item))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Storage.get_storage_item!(id)
    {:ok, _} = Storage.delete_storage_item(item)
    send_resp(conn, :no_content, "")
  end

  defp serialize(i),
    do: %{
      id: i.id,
      path: i.path,
      mime_type: i.mime_type,
      byte_size: i.byte_size,
      server_id: i.server_id,
      uploader_id: i.uploader_id,
      inserted_at: i.inserted_at
    }
end
