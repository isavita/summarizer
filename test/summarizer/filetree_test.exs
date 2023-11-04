defmodule Summarizer.FiletreeTest do
  use ExUnit.Case
  alias Summarizer.Filetree

  describe "generate_file_tree/1" do
    setup do
      dir = "/tmp/test_dir"
      empty_dir = "/tmp/empty_test_dir"
      File.mkdir_p!(dir)
      File.mkdir_p!(empty_dir)
      File.mkdir_p!("#{dir}/nested")
      File.write!("#{dir}/file1.txt", "Content of file 1")
      File.write!("#{dir}/file2.txt", "Content of file 2")
      File.write!("#{dir}/nested/file3.txt", "Content of file 3")

      on_exit(fn ->
        File.rm_rf!(dir)
        File.rm_rf!(empty_dir)
      end)

      {:ok, dir: dir, empty_dir: empty_dir}
    end

    test "returns empty list when empty direcotry", %{empty_dir: empty_dir} do
      assert Filetree.generate_file_tree(empty_dir) == []
    end

    test "returns all files and directories", %{dir: dir} do
      expected = [
        "#{dir}/file1.txt",
        "#{dir}/file2.txt",
        "#{dir}/nested",
        "#{dir}/nested/file3.txt"
      ]

      actual = Filetree.generate_file_tree(dir)
      assert Enum.sort(actual) == Enum.sort(expected)
    end

    test "returns files only", %{dir: dir} do
      expected_files = [
        "#{dir}/file1.txt",
        "#{dir}/file2.txt",
        "#{dir}/nested/file3.txt"
      ]

      actual_files = Filetree.generate_file_tree(dir, files_only: true)
      assert Enum.sort(actual_files) == Enum.sort(expected_files)
    end
  end
end
