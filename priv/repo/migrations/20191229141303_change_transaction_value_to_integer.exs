defmodule Banking.Repo.Migrations.ChangeTransactionValueToInteger do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      remove :value
      add :value_in_cents, :integer
    end
  end
end
