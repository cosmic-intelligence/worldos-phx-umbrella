defmodule Core.Repo.Migrations.CreateStorageItems do
  use Ecto.Migration

  def change do
    create table(:storage_items, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all), null: false
      add :uploader_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :path, :text, null: false
      add :mime_type, :text, null: false
      add :byte_size, :integer, null: false

      timestamps(updated_at: false)
    end

    create index(:storage_items, [:server_id])
    create index(:storage_items, [:uploader_id])
  end
end
