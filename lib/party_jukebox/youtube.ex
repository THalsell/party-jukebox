defmodule PartyJukebox.YouTube do
  @moduledoc """
  Handles YouTube API interactions for searching songs.
  """

  @base_url "https://www.googleapis.com/youtube/v3"

  defp decode_html_entities(text) do
  text
  |> String.replace("&amp;", "&")
  |> String.replace("&#39;", "'")
  |> String.replace("&quot;", "\"")
  |> String.replace("&lt;", "<")
  |> String.replace("&gt;", ">")
end

  def search(query, max_results \\ 10) do
    api_key = System.get_env("YOUTUBE_API_KEY")

    if !api_key do
      {:error, "YouTube API key not configured"}
    else
      url = "#{@base_url}/search?" <>
            URI.encode_query(%{
              part: "snippet",
              q: query,
              type: "video",
              videoCategoryId: "10", # Music category
              maxResults: max_results,
              key: api_key
            })

      case HTTPoison.get(url) do
        {:ok, %{status_code: 200, body: body}} ->
          parse_search_results(body)

        {:ok, %{status_code: status_code}} ->
          {:error, "YouTube API returned status #{status_code}"}

        {:error, %{reason: reason}} ->
          {:error, "Failed to connect to YouTube API: #{reason}"}
      end
    end
  end

  defp parse_search_results(body) do
    case Jason.decode(body) do
      {:ok, %{"items" => items}} ->
        results = Enum.map(items, fn item ->
  %{
    video_id: item["id"]["videoId"],
    title: decode_html_entities(item["snippet"]["title"]),
    channel: decode_html_entities(item["snippet"]["channelTitle"]),
    thumbnail: item["snippet"]["thumbnails"]["default"]["url"]
  }
end)
        {:ok, results}
      
      {:error, _} ->
        {:error, "Failed to parse YouTube response"}
    end
  end
end