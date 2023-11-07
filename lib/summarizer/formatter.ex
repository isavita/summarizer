defmodule Summarizer.Formatter do
  def format_tree(tree_list), do: Enum.map_join(tree_list, "\n", &format_node/1)

  defp format_node(node) do
    is_directory = String.ends_with?(node, "/")
    depth = String.graphemes(node) |> Enum.filter(&(&1 == "/")) |> length()
    indentation = String.duplicate("  ", depth)
    indentation <> Path.basename(node) <> if(is_directory, do: "/", else: "")
  end

  def format_tree_xml(file_paths) do
    "<Files>\n" <> Enum.map_join(file_paths, "\n", &"<File>#{&1}</File>") <> "\n</Files>"
  end
end
