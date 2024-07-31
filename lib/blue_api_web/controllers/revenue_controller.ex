defmodule BlueApiWeb.RevenueController do
  use BlueApiWeb, :controller

  def index(conn, params) do
    with {:ok, to} <- get_to(params),
         {days, ""} <- get_days(params),
         {:ok, from} <- get_from(to, days, params),
         {:ok, result} <- compile_range(from, to) do
      total = Map.values(result) |> Enum.reduce(&sum_rewards/2)
      json(conn, %{days: result, total: total})
    end
  end

  defp get_to(%{"to" => x}), do: NaiveDateTime.from_iso8601(x)
  defp get_to(%{}), do: {:ok, NaiveDateTime.beginning_of_day(NaiveDateTime.local_now())}

  defp get_from(_, _, %{"from" => x}), do: NaiveDateTime.from_iso8601(x)
  defp get_from(to, days, %{}), do: {:ok, NaiveDateTime.add(to, -days, :day)}

  defp get_days(%{"days" => x}), do: Integer.parse(x)
  defp get_days(%{}), do: {7, ""}

  defp compile_range(from, to) do
    {:ok,
     Range.new(0, NaiveDateTime.diff(to, from, :day))
     |> Task.async_stream(
       fn x ->
         {NaiveDateTime.add(from, x - 1, :day),
          BlueApi.Revenue.total_revenue(
            NaiveDateTime.add(from, x - 1, :day),
            NaiveDateTime.add(from, x, :day)
          )}
       end,
       timeout: :infinity
     )
     |> Enum.reduce(%{}, fn {:ok, {date, {:ok, revenue}}}, agg ->
       Map.put(agg, date, revenue)
     end)}
  end

  defp sum_rewards(a, b) do
    Enum.reduce(a, b, fn {k, v}, agg ->
      Map.update(agg, k, v, &(&1 + v))
    end)
  end
end
