defmodule Summarizer.AnthropicUtils do
  @moduledoc false
  import SweetXml

  @doc """
  Extracts the completion from the response body.

  Successful response:
  ```json
  {
    "completion": " Okay, let's solve this step-by-step:\n42 * 38\n= 42 * (30 + 8) \n= 42 * 30 + 42 * 8\n= 1260 + 336\n= 1596\n\nTherefore, 42 * 38 = 1596.",
    "stop_reason": "stop_sequence",
    "model": "claude-2.0",
    "stop": "\n\nHuman:",
    "log_id": "00c6b4ba97de04c5329dc50c0124e4814dfc3252d751afd55bcfaad44023be6d"
  }
  ```

  Error response:
  ```json
  {
    "error": {
      "type": "not_found_error",
      "message": "Not found"
    }
  }
  ```
  """
  @spec extract_complete(map()) :: binary()
  def extract_complete(body) do
    if body["stop"] == "\n\nHuman:" do
      body["completion"]
    else
      "NOT COMPLETED"
    end
  end

  def compose_file_tree_analysis_message(file_tree) do
    """
    \n\nHuman:
    #{file_tree}
    We are looking to summarize the project based on the files provided in the file tree.
    The goal is to identify the most crucial files that, when read, give a comprehensive understanding of what the project is about and how to use it.
    Please analyze the file tree and provide a list of the most important files for this purpose.
    It is crucial that the response contains only the specified <xml> tags with the important file paths and nothing else.
    <Files>
      <File>/path/to/file1.ext</File>
      <File>/path/to/file2.ext</File>
      <!-- More files as needed -->
    </Files>\n\n
    Assistant:
    """
  end

  def compose_files_summary_message(files_contents) do
    files_xml = files_contents_to_xml(files_contents)

    """
    \n\nHuman:
    <FileContents>
      #{files_xml}
    </FileContents>
    Please provide a summary for each of the files provided above.
    The summaries should be concise, clear, and tailored for programmers familiar with the programming language but not with the project.
    The output should be grouped under the <FileSummaries> tag with each file's summary encapsulated within a <FileSummary> tag alongside its file path.
    It is crucial that the response contains only the specified <xml> tags with the file summaries and nothing else.
    <FileSummaries>
      <FileSummary>
        <File>/path/to/merge_sort.cpp</File>
        <Summary>This C++ file contains an implementation of the Merge Sort algorithm, which is a stable, efficient sorting algorithm with a time complexity of O(n log n). The implementation leverages recursion to divide the input array into smaller chunks, sort them individually, and then merge them back together in sorted order.</Summary>
      </FileSummary>
    </FileSummaries>\n\n
    Assistant:<FileSummaries>
    """
  end

  defp files_contents_to_xml(files_contents) do
    files_contents
    |> Enum.map(fn {file_path, content} ->
      """
      <FileContent>
        <File>#{file_path}</File>
        <Content>#{content}</Content>
      </FileContent>
      """
    end)
    |> Enum.join("\n")
  end

  def compose_final_summary_message(combined_summary) do
    """
    \n\nHuman:
    #{combined_summary}
    The text provided above is a collection of summaries for important files in a project.
    The goal is to obtain a concise and clear summary for the README file that gives an overview of the project based on these summaries.
    Please provide a summarization that can serve as an introduction to the project.
    The summarization should offer a detailed description of the project, elaborating on its objectives, functionality, and how to use it, targeting other programmers as the audience. It is essential that this summary is comprehensive and serves as the entire README, guiding users effectively on how to interact with the project.
    It is crucial that the response is formatted with the summarization enclosed within the <ReadmeFile> XML tag as shown in the example: <ReadmeFile>{{README}}</ReadmeFile>.

    For your reference, Markdown allows text styling with simple symbols:
    - **Bold** with `**bold**`
    - _Italic_ with `*italic*`
    - `Code` with backticks
    - Headers with `#` for H1, `##` for H2, and so on
    - Bullet lists with `-` or `*` at the start of a line
    - Numbered lists with `1.`, `2.`, etc., at the start of a line
    <ReadmeFile>
    {{README}}}
    </ReadmeFile>\n\n
    Assistant:
    """
  end

  def parse_compose_file_tree_analysis_message_response(body) do
    try do
      body = Regex.replace(~r{<files>}, body, "<Files>")
      body = Regex.replace(~r{</files>}, body, "</Files>")
      body = Regex.replace(~r{<file>}, body, "<File>")
      body = Regex.replace(~r{</file>}, body, "</File>")

      case String.split(body, ~r{<Files>}, parts: 2) do
        [_, rest] ->
          xml_content = "<Files>" <> String.trim(rest)
          parsed_response = xml_content |> xpath(~x"//Files/File/text()"l, [])

          case parsed_response do
            [] -> {:error, "Error: No files found in <Files> tag"}
            file_paths -> {:ok, file_paths |> Enum.map(&to_string/1)}
          end

        _ ->
          {:error, "Error: No <Files> tag found"}
      end
    catch
      :exit, _ -> {:error, "Error: Cannot parse the response"}
    end
  end

  def parse_summarize_text_to_readme_response(body) do
    try do
      body = Regex.replace(~r{<readmefile>}i, body, "<ReadmeFile>")
      body = Regex.replace(~r{</readmefile>}i, body, "</ReadmeFile>")

      case String.split(body, ~r{<ReadmeFile>}, parts: 2) do
        [_, rest] ->
          xml_content = "<ReadmeFile>" <> String.trim(rest)
          parsed_response = xml_content |> xpath(~x"//ReadmeFile/text()"l, [])

          case parsed_response do
            [] -> {:error, "Error: No content found in <ReadmeFile> tag"}
            [summary] -> {:ok, to_string(summary) |> String.trim()}
          end

        _ ->
          {:error, "Error: No <ReadmeFile> tag found"}
      end
    catch
      :exit, _ -> {:error, "Error: Cannot parse the response"}
    end
  end

  def compose_validate_summary_message(summary) do
    """
    \n\nHuman:
    The text provided below is intended to be a README file for a project:
    #{summary}
    <ReadmeFile>{{README}}</ReadmeFile>

    Please review the README content for any harmful content or personally identifiable information (PII). If any harmful content or PII is detected, please indicate it by responding with "HARMFUL CONTENT". If no such issues are present, please respond with "PASS".
    \n\nAssistant:
    """
  end

  def check_validate_summary_response(resp_body) do
    case String.contains?(String.downcase(resp_body), "harmful content") do
      true -> {:error, "HARMFUL CONTENT"}
      false -> :ok
    end
  end
end
