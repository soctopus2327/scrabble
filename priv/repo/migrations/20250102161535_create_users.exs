defmodule Scrabble.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :userid, :string, null: false
      add :passwd_hash, :string, null: false  # Changed from passwd to passwd_hash
      add :score, :integer, default: 0
      timestamps()
    end

    create unique_index(:users, [:userid])
  end
end
