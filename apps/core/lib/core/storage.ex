defmodule Core.Storage do
  @moduledoc """
  Context for uploaded storage items.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Storage.StorageItem

  def list_storage_items(server_id \\ nil) do
    query =
      if server_id,
        do: from(s in StorageItem, where: s.server_id == ^server_id),
        else: StorageItem

    Repo.all(query)
  end

  def get_storage_item!(id), do: Repo.get!(StorageItem, id)

  def create_storage_item(attrs \\ %{}) do
    %StorageItem{}
    |> StorageItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_storage_item(%StorageItem{} = item, attrs) do
    item
    |> StorageItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_storage_item(%StorageItem{} = item), do: Repo.delete(item)

  def change_storage_item(%StorageItem{} = item, attrs \\ %{}),
    do: StorageItem.changeset(item, attrs)
end
