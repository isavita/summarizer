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
    tmp_dir = "#{File.cwd!()}/#{random_string()}"
    File.mkdir_p!(tmp_dir)

    if File.exists?(tmp_dir) do
      {:ok, tmp_dir}
    else
      {_output, 0} =
        System.cmd(
          "git",
          ["clone", "--depth", "1", github_url, tmp_dir],
          stderr_to_stdout: true
        )

      {:ok, tmp_dir}
    end
  end

  defp random_string(length \\ 8) do
    :crypto.strong_rand_bytes(4) |> Base.encode16() |> binary_part(0, length)
  end
end
