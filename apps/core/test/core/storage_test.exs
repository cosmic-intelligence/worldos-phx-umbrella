defmodule Core.StorageTest do
  use Core.DataCase, async: true

  alias Core.{Accounts, Servers, Storage}
  alias Core.Storage.StorageItem

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        username: "uploader",
        email: "up@example.com",
        hashed_password: "hash"
      })

    {:ok, srv} = Servers.create_server(%{name: "Srv", owner_id: user.id})
    {:ok, user: user, server: srv}
  end

  test "create_storage_item/1", %{user: user, server: srv} do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "files/doc.txt",
        mime_type: "text/plain",
        byte_size: 123,
        server_id: srv.id,
        uploader_id: user.id
      })

    assert %StorageItem{} = Storage.get_storage_item!(item.id)
    assert item.byte_size == 123
  end
end
