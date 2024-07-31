defmodule BlueApi.Revenue.Snapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "revenue_snapshots" do
    field :from, :naive_datetime
    field :to, :naive_datetime
    field :revenue, :map

    timestamps()
  end

  @doc false
  def changeset(snapshot, attrs) do
    snapshot
    |> cast(attrs, [:from, :to, :revenue])
    |> validate_required([:from, :to, :revenue])
  end
end
