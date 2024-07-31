defmodule BlueApi.Repo.Migrations.CreateRevenueSnapshots do
  use Ecto.Migration

  def change do
    create table(:revenue_snapshots) do
      add :from, :naive_datetime
      add :to, :naive_datetime
      add :revenue, :map

      timestamps()
    end

    create index(:revenue_snapshots, :from)
    create index(:revenue_snapshots, :to)
  end
end
