defmodule Core.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :server_id, references(:servers, type: :uuid, on_delete: :delete_all),
        null: false,
        primary_key: true

      add :role, :smallint, null: false, default: 0
      add :joined_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:server_id])
  end
end
