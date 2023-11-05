defmodule Summarizer do
  @moduledoc false

  alias Summarizer.AnthropicHTTPClient
  alias Summarizer.FileGrouper
  alias Summarizer.Filetree
  alias Summarizer.Filter
  alias Summarizer.Formatter
  alias Summarizer.AnthropicUtils, as: Utils

  # assuming that a token is more than 1 char long
  @max_file_tree_size 110_000

  def summarize(path) do
    with {:ok, important_files} <- identify_important_files(path),
         {:ok, summary} <- summarize_project(important_files),
         {:ok, validated_summary} <- validate_summary(summary) do
      {:ok, validated_summary}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def identify_important_files(path) do
    message =
      path
      |> generate_file_tree()
      |> String.slice(0, @max_file_tree_size)
      |> Utils.compose_file_tree_analysis_message()

    with {:ok, resp_body} <- AnthropicHTTPClient.complete(message, max_tokens_to_sample: 99_000),
         {:ok, important_files} <-
           Utils.parse_compose_file_tree_analysis_message_response(resp_body) do
      {:ok, important_files}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp summarize_project(important_files) do
    file_groups = FileGrouper.map_files_to_structs(important_files)

    summaries =
      Enum.map(file_groups, &summarize_group/1)
      |> Enum.filter(fn
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, summary} -> summary end)

    if length(summaries) > 1 do
      summaries
      |> Enum.join("\n")
      |> summarize_text_to_readme()
    else
      List.first(summaries)
      |> summarize_text_to_readme()
    end
  end

  defp summarize_group(%FileGrouper{files_contents: files_contents}) do
    message = Utils.compose_files_summary_message(files_contents)

    with {:ok, resp_body} <- AnthropicHTTPClient.complete(message, max_tokens_to_sample: 95_000) do
      {:ok, resp_body}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp summarize_text_to_readme(combined_summary) do
    message = Utils.compose_final_summary_message(combined_summary)

    with {:ok, resp_body} <- AnthropicHTTPClient.complete(message, max_tokens_to_sample: 95_000),
         {:ok, readme_text} <- Utils.parse_summarize_text_to_readme_response(resp_body) do
      {:ok, readme_text}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_summary(summary), do: {:ok, summary}

  def generate_file_tree(path) when is_binary(path) do
    path
    |> Filetree.generate_file_tree(files_only: true)
    |> Filter.filter_files()
    |> Formatter.format_tree_xml()
  end

  def generate_file_tree(_) do
    raise ArgumentError, "path must be a string"
  end
end
