defmodule Bakeit do

  @pastery_url "https://www.pastery.net/api/paste/"

  def upload(input, opts) do
    api_key = Bakeit.INI.read[:api_key]
    opts[:debug] && (
     IO.write "Opts: #{inspect opts}\n"
     IO.write "#{api_key}\n"
   )

   HTTPoison.start

   body = get_body(input)
   headers = %{"User-Agent"   => "Mozilla/5.0 (Elixir) bakeit library",
               "Content-Type" => "application/octet-stream"}
   post_opts = [
                 follow_redirect: true,
                 params: make_qps(api_key, opts),
                 ssl: []
               ]

   IO.write "Uploading to Pastery...\n"

   {:ok, resp} = HTTPoison.post(@pastery_url, body, headers, post_opts)
   opts[:debug] && IO.write("Resp: #{inspect resp}\n")

   {:ok, resp_body} = parse_upload_rsp(resp)
   {:ok, paste_resp} = Poison.decode(resp_body)
   paste_url = paste_resp["url"]
   IO.write "Paste URL: #{paste_url}\n"
   :ok = maybe_launch_webbrowser(paste_url, opts)
  end

  defp get_body(""), do: IO.getn("", 1024 * 1024)
  defp get_body(fname), do: {:file, fname}

  defp maybe_launch_webbrowser(url, cfg) do
    (cfg[:open_browser] && launch_webbrowser(url); :ok)
  end

  defp launch_webbrowser(<<url :: binary>>) do
    url |> String.to_char_list |> launch_webbrowser
  end
  defp launch_webbrowser(url) do
    case :webbrowser.open(url) do
      :ok ->
        true;
      {:error, {:not_found, msg}} ->
        IO.write "#{msg}\n"
        false
    end
  end

  defp title_or_filename(cfg, files) do
    case cfg[:title] do
      "" ->
        get_filename(files)
      title ->
        title
    end
  end

  defp get_filename([fname|_]), do: Path.basename(fname)
  defp get_filename([]), do: []

  defp make_qps(api_key, opts) do
    [api_key: api_key] ++
    opt_qp(:title, opts, &str_nonempty?/1) ++
    opt_qp(:language, opts, &str_nonempty?/1) ++
    opt_qp(:duration, opts, &non_zero?/1) ++
    opt_qp(:max_views, opts, &non_zero?/1)
  end

  defp opt_qp(key, opts, pred) do
    val = opts[key]
    pred.(val) && [{key, val}] || []
  end

  defp str_nonempty?(s), do: s != ""
  defp non_zero?(i), do: i != 0

  defp parse_upload_rsp(resp) do
    case resp.status_code do
      n when n in 300..399 ->
        msg = "Unexpected redirect: #{n} #"
        {:error, msg}
      413 ->
        {:error, "The chosen file was rejected by the server " <>
                 "because it was too large, please try a smaller " <>
                 "file."}
      422 ->
        {:error, "422"}
      n when n in 400..499 ->
        {:error, "There was a problem with the request: #{n}"}
      n when n >= 500 ->
        msg = "There was a server error #{n}, please try again later."
        {:error, msg}
      _ ->
        {:ok, resp.body}
    end
  end

end
