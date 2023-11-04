defmodule Summarizer.AnthropicUtilsTest do
  use ExUnit.Case

  alias Summarizer.AnthropicUtils, as: Utils

  describe "parse_compose_file_tree_analysis_message_response/1" do
    @successful_response """
      <Files>
        <File>/path/to/file1.ext</File>
        <File>/path/to/file2.ext</File>
      </Files>
    """

    @incomplete_response """
      <Files>
        <File>/path/to/file1.ext</File
    """

    @lowercase_response """
      <files>
        <file>/path/to/file1.ext</file>
        <file>/path/to/file2.ext</file>
      </files>
    """

    @no_files_tag_response """
      <File>/path/to/file1.ext</File>
      <File>/path/to/file2.ext</File>
    """

    setup do
      old_level = Logger.level()
      :ok = Logger.configure(level: :critical)
      on_exit(fn -> :ok = Logger.configure(level: old_level) end)
    end

    test "successful parsing" do
      assert {:ok, ["/path/to/file1.ext", "/path/to/file2.ext"]} ==
               Utils.parse_compose_file_tree_analysis_message_response(@successful_response)
    end

    test "successful parsing lowercase tags" do
      assert {:ok, ["/path/to/file1.ext", "/path/to/file2.ext"]} ==
               Utils.parse_compose_file_tree_analysis_message_response(@lowercase_response)
    end

    test "incomplete XML" do
      assert {:error, "Error: Cannot parse the response"} ==
               Utils.parse_compose_file_tree_analysis_message_response(@incomplete_response)
    end

    test "no <Files> tag" do
      assert {:error, "Error: No <Files> tag found"} ==
               Utils.parse_compose_file_tree_analysis_message_response(@no_files_tag_response)
    end
  end
end
