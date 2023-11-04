defmodule Summarizer do
  @moduledoc false

  alias Summarizer.AnthropicHTTPClient
  alias Summarizer.FileGrouper
  alias Summarizer.Filetree
  alias Summarizer.Filter
  alias Summarizer.Formatter
  alias Summarizer.AnthropicUtils, as: Utils

  def summarize(path) do
    # Add few function that should called claude api
    # The first should be to ask the model which files are important to the model
    # The second should make the call to the model with the content of the files and ask to make a summary of the project
    # The third for the moment will do nothing but simply return what is given but in the future we will implement validation that the content is appropriate and some sanity checks
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
      |> Utils.compose_file_tree_analysis_message()

    with {:ok, resp_body} <- AnthropicHTTPClient.complete(message),
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
      |> Enum.filter(fn {:ok, _} -> true; _ -> false end)
      |> Enum.map(fn {:ok, summary} -> summary end)

    if length(summaries) > 1 do
      combined_summary = Enum.join(summaries, "\n")
      summarize_text(combined_summary)
    else
      List.first(summaries)
    end
  end

  defp summarize_group(%FileGrouper{files_contents: files_contents}) do
    message = Utils.compose_files_summary_message(files_contents)

    with {:ok, resp_body} <- AnthropicHTTPClient.complete(message, max_tokens_to_sample: 95_000)
      {:ok, resp_body}
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
