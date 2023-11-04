defmodule Summarizer do
  @moduledoc false

  alias Summarizer.AnthropicHTTPClient
  alias Summarizer.Filetree
  alias Summarizer.Filter
  alias Summarizer.Formatter
  alias Summarizer.AnthropicUtils

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
    path
    |> generate_file_tree()
    |> AnthropicUtils.compose_file_tree_analysis_message()
    |> AnthropicHTTPClient.complete()
  end

  defp summarize_project(important_files) do
    # # Assume get_file_content/1 reads the file and returns its content
    # file_contents = Enum.map(important_files, &get_file_content/1)
    # # Assuming the file_contents is formatted as a string
    # response = AnthropicHTTPClient.complete("Summarize Project", Enum.join(file_contents, "\n"))
    # # Assume the response contains the summary of the project
    # summary = parse_response(response)
    # summary
    {:ok, important_files}
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
