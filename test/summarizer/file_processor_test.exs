defmodule Summarizer.FileProcessorTest do
  use ExUnit.Case

  alias Summarizer.FileProcessor

  describe "read_limited_lines/2" do
    setup do
      # Create a file with a specified number of lines
      file_path = "/tmp/file_processor_test.txt"

      File.open!(file_path, [:write], fn file ->
        1..2500
        |> Enum.each(fn i -> IO.write(file, "#{Integer.to_string(i)}\n") end)
      end)

      # The on_exit callback ensures the file is deleted after the test
      on_exit(fn -> File.rm(file_path) end)

      # Pass the file path to the test
      {:ok, file_path: file_path}
    end

    test "reads up to the line limit from a file", %{file_path: file_path} do
      content = FileProcessor.read_limited_lines(file_path)
      assert String.split(content, "\n") |> length() == 2001
    end

    test "returns an empty string if the file does not exist" do
      non_existent_file = "/tmp/nonexistentfile.txt"
      assert FileProcessor.read_limited_lines(non_existent_file) == ""
    end
  end
end
