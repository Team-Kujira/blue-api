defmodule BlueApi.RevenueTest do
  use ExUnit.Case
  use BlueApi.DataCase

  test "collects revenue data" do
    {:ok, %{}} = fetch_day()

    # Ensure the second one is fast - ie comes from the database
    {time, {:ok, %{}}} = :timer.tc(&fetch_day/0, [])
    assert(time < 1000)
  end

  defp fetch_day() do
    {:ok, %{}} =
      BlueApi.Revenue.total_revenue(
        NaiveDateTime.from_iso8601!("2024-07-30T00:00:00Z"),
        NaiveDateTime.from_iso8601!("2024-07-31T00:00:00Z")
      )
  end
end
