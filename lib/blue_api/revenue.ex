defmodule BlueApi.Revenue do
  require Logger
  alias BlueApi.Revenue.Snapshot
  alias BlueApi.Repo
  alias GoogleApi.BigQuery.V2.Model.TableRow
  alias GoogleApi.BigQuery.V2.Model.TableCell
  alias GoogleApi.BigQuery.V2.Api.Jobs
  alias GoogleApi.BigQuery.V2.Connection
  alias GoogleApi.BigQuery.V2.Model.QueryRequest
  alias GoogleApi.BigQuery.V2.Model.QueryResponse
  alias GoogleApi.BigQuery.V2.Model.JobReference
  alias GoogleApi.BigQuery.V2.Model.GetQueryResultsResponse
  import Ecto.Query

  @project_id "kujira-api"
  @regex ~r'([0-9]+)([a-zA-Z][a-zA-Z0-9/:._-]{2,127})'

  def total_revenue(from, to) do
    case Repo.one(from s in Snapshot, where: s.from == ^from and s.to == ^to) do
      nil ->
        with {:ok, rows} when is_list(rows) <- revenue_query(from, to) do
          revenue = Enum.reduce(rows, %{}, &add_result/2)

          %Snapshot{}
          |> Snapshot.changeset(%{from: from, to: to, revenue: revenue})
          |> Repo.insert()

          {:ok, revenue}
        end

      %{revenue: revenue} ->
        {:ok, revenue}
    end
  end

  defp revenue_query(from, to) do
    query = """
    SELECT b.attribute_value, a.ingestion_timestamp
    FROM `numia-data.kaiyo.kaiyo_event_attributes` a, `numia-data.kaiyo.kaiyo_event_attributes` b
    WHERE a.attribute_key='receiver'
      AND a.attribute_value='kujira17xpfvakm2amg962yls6f84z3kell8c5lp3pcxh'
      AND a.tx_id=b.tx_id
      AND a.event_index=b.event_index
      AND b.attribute_key='amount'
      AND a.ingestion_timestamp >= (TIMESTAMP '#{NaiveDateTime.to_iso8601(from)}')
      AND a.ingestion_timestamp < (TIMESTAMP '#{NaiveDateTime.to_iso8601(to)}')
    ORDER BY a.block_height DESC
    """

    request = %QueryRequest{
      query: query,
      useLegacySql: false,
      parameterMode: "NAMED"
    }

    execute_query(request)
  end

  defp add_result(
         %TableRow{f: [%TableCell{v: coins} | _]},
         agg
       ) do
    @regex
    |> Regex.scan(coins)
    |> Enum.reduce(agg, fn [_, amount, token], a ->
      Map.update(a, token, String.to_integer(amount), &(&1 + String.to_integer(amount)))
    end)
  end

  def execute_query(request) do
    {:ok, token} = Goth.fetch(BlueApi.Goth)
    conn = Connection.new(token.token)

    case Jobs.bigquery_jobs_query(conn, @project_id, body: request) do
      {:ok, %QueryResponse{jobComplete: true, rows: rows}} ->
        {:ok, rows}

      {:ok,
       %QueryResponse{
         jobReference: %JobReference{jobId: id},
         jobComplete: false
       }} ->
        query_job(conn, id)

      {:error, %{body: body}} ->
        {:error, Jason.decode!(body)["error"]}
    end
  end

  defp query_job(conn, id, page_token \\ nil) do
    Logger.info("#{__MODULE__} #{id} Fetching Page #{page_token}")

    case Jobs.bigquery_jobs_get_query_results(conn, @project_id, id,
           pageToken: page_token,
           maxResults: 100_000
         ) do
      {:ok, %GetQueryResultsResponse{jobComplete: false}} ->
        Logger.info("#{__MODULE__} #{id} Incomplete")
        Process.sleep(1000)
        query_job(conn, id)

      {:ok, %GetQueryResultsResponse{rows: rows, jobComplete: true, pageToken: nil}} ->
        Logger.info("#{__MODULE__} #{id} Complete")
        {:ok, rows}

      {:ok,
       %GetQueryResultsResponse{
         totalRows: total,
         rows: x,
         jobComplete: true,
         pageToken: page_token
       }} ->
        Logger.info("#{__MODULE__} #{id} Total #{total} Paging #{page_token}")

        with {:ok, y} <- query_job(conn, id, page_token) do
          {:ok, x ++ y}
        end

      {:error, err} ->
        {:error, err}
    end
  end
end
