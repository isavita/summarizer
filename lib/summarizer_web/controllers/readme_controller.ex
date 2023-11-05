defmodule SummarizerWeb.ReadmeController do
  use SummarizerWeb, :controller

  def create(conn, %{"url" => github_url}) do
    with {:ok, tmp_dir} <- clone_repo_to_tmp(github_url),
         {:ok, summary} <- Summarizer.summarize(tmp_dir),
         {:ok, _} <- File.rm_rf(tmp_dir) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, Jason.encode!(%{data: summary}))
    else
      {:error, error_msg} -> send_resp(conn, 400, Jason.encode!(%{error: inspect(error_msg)}))
    end
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
