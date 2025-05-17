defmodule Core.Repo.Migrations.CreateAgentMessages do
  use Ecto.Migration

  def change do
    create table(:agent_messages) do
      add :agent_id, references(:ai_agents, type: :uuid, on_delete: :delete_all), null: false
      add :channel_id, references(:channels, type: :uuid, on_delete: :nilify_all), null: false
      add :content, :text, null: false

      timestamps(updated_at: false)
    end

    create index(:agent_messages, [:agent_id])
    create index(:agent_messages, [:channel_id])
  end
end
