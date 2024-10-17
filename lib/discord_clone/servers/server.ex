defmodule DiscordClone.Servers.Server do
  use Ecto.Schema
  import Ecto.Changeset

  schema "servers" do
    field :name, :string
    has_many :channels, DiscordClone.Channels.Channel

    timestamps()
  end

  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
