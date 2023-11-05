defmodule SummarizerWeb.ReadmeController do
  use SummarizerWeb, :controller

  def create(conn, %{"url" => github_url}) do
    with {:ok, repo_name} <- extract_repo_name(github_url),
         {:ok, dir} <- clone_repo_to_tmp(repo_name),
         {:ok, summary} <- Summarizer.summarize(dir) do
      json(conn, %{data: summary})
    else
      {:error, error_msg} -> send_resp(conn, 400, Jason.encode!(%{error: inspect(error_msg)}))
    end
  end

  defp clone_repo_to_tmp(repo_name) do
    tmp_dir = "/tmp/#{repo_name}"

    if File.exists?(tmp_dir) do
      {:ok, tmp_dir}
    else
      # Clone the repository
      {_output, 0} =
        System.cmd(
          "git",
          ["clone", "--depth", "1", "https://github.com/#{repo_name}.git", tmp_dir],
          stderr_to_stdout: true
        )

      {:ok, tmp_dir}
    end
  end

  defp extract_repo_name(url) do
    # Parse the URL to extract the GitHub repository path
    case URI.parse(url) do
      %URI{host: "github.com", path: "" <> path} ->
        # Strip leading slash and extract the repo name
        repo_name = path |> String.trim_leading("/") |> String.replace(~r{/+$}, "")
        {:ok, repo_name}

      _ ->
        {:error, "Invalid GitHub URL."}
    end
  end
end
