defmodule Core.Repo.Migrations.AddInsertedAtToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end
  end
end
