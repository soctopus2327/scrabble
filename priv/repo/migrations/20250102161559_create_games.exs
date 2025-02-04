defmodule Scrabble.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :code, :string, null: false
      add :creator_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index(:games, [:code])
  end
end
