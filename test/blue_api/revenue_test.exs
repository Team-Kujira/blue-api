defmodule BlueApi.RevenueTest do
  use ExUnit.Case

  test "collects a small set of data" do
    {:ok, %{}} =
      BlueApi.Revenue.total_revenue(
        NaiveDateTime.from_iso8601!("2024-07-31T00:00:00Z"),
        NaiveDateTime.from_iso8601!("2024-07-31T01:00:00Z")
      )
  end

  test "collects a large set of data" do
    {:ok, %{}} =
      BlueApi.Revenue.total_revenue(
        NaiveDateTime.from_iso8601!("2024-06-31T00:00:00Z"),
        NaiveDateTime.from_iso8601!("2024-07-31T00:00:00Z")
      )
  end
end
