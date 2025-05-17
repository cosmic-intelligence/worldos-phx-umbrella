defmodule Core.Repo.Migrations.CreateAiAgents do
  use Ecto.Migration

  def change do
    create table(:ai_agents, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all), null: false
      add :creator_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :name, :text, null: false
      add :config, :map, null: false

      timestamps(updated_at: false)
    end

    create index(:ai_agents, [:server_id])
    create index(:ai_agents, [:creator_id])
  end
end
