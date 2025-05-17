defmodule Core.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext")
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"")

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :username, :citext, null: false
      add :email, :citext, null: false
      add :hashed_password, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
