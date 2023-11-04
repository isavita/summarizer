defmodule Summarizer.FileGrouperTest do
  use ExUnit.Case

  alias Summarizer.FileGrouper

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
      content = FileGrouper.read_limited_lines(file_path)
      assert String.split(content, "\n") |> length() == 2001
    end

    test "returns an empty string if the file does not exist" do
      non_existent_file = "/tmp/nonexistentfile.txt"
      assert FileGrouper.read_limited_lines(non_existent_file) == ""
    end
  end

  describe "map_files_to_structs/2" do
    setup do
      # Create temporary files with known content
      files = for i <- 1..3, do: "/tmp/test_file_#{i}.txt"

      Enum.each(files, fn file ->
        # Each file has 100,000 characters
        File.write!(file, String.duplicate("a", 100_000))
      end)

      on_exit(fn ->
        # Delete the temporary files after the test
        Enum.each(files, &File.rm/1)
      end)

      {:ok, files: files}
    end

    test "includes all files in a single struct when under the limit", context do
      files = context[:files]
      structs = FileGrouper.map_files_to_structs(files, 400_000)

      assert length(structs) == 1
      assert Enum.all?(structs, fn %FileGrouper{current_size: size} -> size <= 400_000 end)

      assert Enum.all?(structs, fn %FileGrouper{files_contents: contents} ->
               length(contents) == length(files)
             end)
    end

    test "creates multiple structs and truncates the last file when over the limit", %{
      files: files
    } do
      large_file = "/tmp/test_large_file.txt"
      File.write!(large_file, String.duplicate("a", 300_000))
      files = files ++ [large_file]

      on_exit(fn -> File.rm(large_file) end)

      structs = FileGrouper.map_files_to_structs(files, 400_000)

      assert length(structs) > 1
      assert Enum.all?(structs, fn %FileGrouper{current_size: size} -> size <= 400_000 end)

      assert byte_size(List.last(structs).files_contents |> List.first() |> elem(1)) <=
               400_000 - 3 * 100_000
    end
  end
end
