defmodule SummarizerWeb.ReadmeController do
  use SummarizerWeb, :controller

  def index(conn, _params) do
    html_form = """
    <html>
      <body>
        <form action="/create" method="post">
          <input type="text" name="url" placeholder="Enter GitHub URL" required>
          <input type="submit" value="Generate README">
        </form>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html_form)
  end

  def create(conn, %{"url" => github_url}) do
    with {:ok, tmp_dir} <- clone_repo_to_tmp(github_url),
         {:ok, summary} <- Summarizer.summarize(tmp_dir),
         {:ok, _} <- File.rm_rf(tmp_dir) do
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(200, success_html(summary))
    else
      {:error, error_msg} ->
        conn
        |> put_resp_content_type("text/html")
        |> send_resp(400, error_html(inspect(error_msg)))
    end
  end

  defp success_html(summary) do
    "<html><body><pre>" <> summary <> "</pre></body></html>"
  end

  defp error_html(error_msg) do
    "<html><body><p>Error: " <> error_msg <> "</p></body></html>"
  end

  defp clone_repo_to_tmp(github_url) do
    random_dir_name = random_string()
    target_dir = "/tmp/#{random_dir_name}"

    case System.cmd("git", ["clone", github_url, target_dir]) do
      {_, 0} ->
        {:ok, target_dir}

      {error_message, _} ->
        {:error, error_message}
    end
  end

  defp random_string(length \\ 8) do
    :crypto.strong_rand_bytes(4) |> Base.encode16() |> binary_part(0, length)
  end
end
