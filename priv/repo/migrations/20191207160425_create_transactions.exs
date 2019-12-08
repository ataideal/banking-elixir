defmodule Banking.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :value, :float
      add :transaction_type, :integer
      add :user_from_id, references(:users, on_delete: :nothing), null: false
      add :user_to_id, references(:users, on_delete: :nothing), null: true

      timestamps()
    end

    create index(:transactions, [:user_from_id])
  end
end
