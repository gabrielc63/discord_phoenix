defmodule DiscordClone.Repo.Migrations.CreateServers do
  use Ecto.Migration

  def change do
    create table(:servers) do
      add :name, :string

      timestamps()
    end
  end
end
