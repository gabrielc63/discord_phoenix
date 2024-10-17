defmodule DiscordClone.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :server_id, references(:servers, on_delete: :nothing)

      timestamps()
    end

    create index(:channels, [:server_id])
  end
end
