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
    Assistant:<Files>
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
end