defmodule InfoSys.Wolfram do
  @moduledoc """
  A WolframAlpha API client that implements `InfoSys.Backend` behaviour.

  ## Examples

    iex> Wolfram.compute("What is elixir?", nil)

    [
      %InfoSys.Result{
        backend: InfoSys.Wolfram,
        score: 95,
        text: "1 | noun | a sweet flavored liquid"
      }
    ]
  """

  import SweetXml
  alias InfoSys.Result

  @behaviour InfoSys.Backend

  @base_url "http://api.wolframalpha.com/v2/query"

  @impl true
  def name do
    "wolfram"
  end

  @impl true
  def compute(query_str, _opts) do
    query_str
    |> fetch_xml()
    # The sigil x returns a SweetXpath struct.
    |> xpath(
      ~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()"
    )
    |> build_results()
  end

  defp build_results(nil) do
    []
  end

  defp build_results(answer) do
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end

  # Accepts a query as a string and fetches answers to the query.
  defp fetch_xml(query) do
    url_charlist = String.to_charlist(build_url_with_query(query))
    {:ok, {_, _, body}} = :httpc.request(url_charlist)
    body
  end

  # WolframAlpha API documentation: https://products.wolframalpha.com/docs/WolframAlpha-API-Reference.pdf
  defp build_url_with_query(query) do
    "#{@base_url}?" <>
      URI.encode_query(
        appid: wolfram_app_id(),
        input: query,
        format: "plaintext"
      )
  end

  defp wolfram_app_id do
    Application.fetch_env!(:info_sys, :wolfram)[:app_id]
  end
end
