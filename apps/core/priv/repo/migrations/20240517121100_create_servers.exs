defmodule Core.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

    create table(:servers, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :owner_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :name, :text, null: false
      add :is_public, :boolean, null: false, default: true

      timestamps(updated_at: false)
    end

    create index(:servers, [:owner_id])
    create unique_index(:servers, [:owner_id, :name])
  end
end
