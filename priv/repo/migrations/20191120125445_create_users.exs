defmodule Banking.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password, :string
      add :balance, :float

      timestamps()
    end
    create unique_index(:users, [:username])
  end
end
