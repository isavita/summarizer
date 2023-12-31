defmodule Summarizer.FormatterTest do
  use ExUnit.Case
  alias Summarizer.Formatter

  test "formats a list into a tree structure" do
    file_structure = [
      "lib/",
      "lib/filetree.ex",
      "lib/filter.ex",
      "test/",
      "test/filetree_test.exs",
      "test/filter_test.exs"
    ]

    expected_output =
      "  lib/\n" <>
        "  filetree.ex\n" <>
        "  filter.ex\n" <>
        "  test/\n" <>
        "  filetree_test.exs\n" <>
        "  filter_test.exs"

    assert Formatter.format_tree(file_structure) == expected_output
  end
end
