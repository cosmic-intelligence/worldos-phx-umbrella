defmodule Core.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all), null: false
      add :name, :text, null: false
      add :is_private, :boolean, null: false, default: false
      add :position, :integer, null: false, default: 0
    end

    create index(:channels, [:server_id])
    create unique_index(:channels, [:server_id, :name])
  end
end
