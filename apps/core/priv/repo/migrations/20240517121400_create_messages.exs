defmodule Core.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :channel_id, references(:channels, type: :uuid, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :content, :text, null: false

      timestamps(updated_at: false)
    end

    create index(:messages, [:channel_id])
    create index(:messages, [:author_id])
  end
end
