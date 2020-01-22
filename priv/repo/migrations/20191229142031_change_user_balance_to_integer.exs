defmodule Banking.Repo.Migrations.ChangeUserBalanceToInteger do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :balance
      add :balance_in_cents, :bigint
    end
  end
end
