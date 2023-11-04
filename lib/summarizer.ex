defmodule Summarizer do
  @moduledoc false

  alias Summarizer.Filetree
  alias Summarizer.Filter
  alias Summarizer.Formatter

  def generate_file_tree(path) when is_binary(path) do
    path
    |> Filetree.generate_file_tree(files_only: true)
    |> Filter.filter_files()
    |> Formatter.format_tree()
  end

  def generate_file_tree(_) do
    raise ArgumentError, "path must be a string"
  end
end
