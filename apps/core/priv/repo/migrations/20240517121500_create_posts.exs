defmodule Core.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all), null: false
      add :author_id, references(:users, type: :uuid, on_delete: :nilify_all), null: false
      add :slug, :text, null: false
      add :title, :text, null: false
      add :html_content, :text, null: false
      add :is_public, :boolean, null: false, default: true

      timestamps(updated_at: false)
    end

    create index(:posts, [:server_id])
    create index(:posts, [:author_id])
    create unique_index(:posts, [:server_id, :slug])
  end
end
