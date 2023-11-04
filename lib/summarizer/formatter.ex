defmodule Summarizer.Formatter do
  def format_tree(tree_list), do: format_tree(tree_list, 0, "")

  defp format_tree([], _depth, _parent), do: ""

  defp format_tree([head | tail], depth, parent) do
    is_directory = String.ends_with?(head, "/")
    part_to_print = if parent != "", do: String.replace_leading(head, parent, ""), else: head
    formatted_head = String.duplicate("  ", depth) <> part_to_print <> "\n"
    new_parent = if is_directory, do: head, else: parent
    count = if(is_directory, do: 1, else: 0)
    formatted_tail = format_tree(tail, depth + count, new_parent)
    formatted_head <> formatted_tail
  end

  def format_tree_xml(file_paths) do
    """
    <Files>
    #{do_format_tree_xml(file_paths)}
    </Files>
    """
  end

  defp do_format_tree_xml([]), do: ""

  defp do_format_tree_xml([head | tail]) do
    "<File>#{head}</File>\n" <> do_format_tree_xml(tail)
  end
end