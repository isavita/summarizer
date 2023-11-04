defmodule Summarizer.Formatter do
  def format_tree(tree_list), do: format_tree(tree_list, 0, "")

  defp format_tree([], _depth, _parent), do: ""

  defp format_tree([head | tail], depth, parent) do
    is_directory = String.ends_with?(head, "/")

    part_to_print =
      if parent != "" do
        String.replace_leading(head, parent, "")
      else
        head
      end

    formatted_head = String.duplicate("  ", depth) <> part_to_print <> "\n"
    new_parent = if is_directory, do: head, else: parent
    count = if(is_directory, do: 1, else: 0)
    formatted_tail = format_tree(tail, depth + count, new_parent)
    # Combine the formatted head and tail
    formatted_head <> formatted_tail
  end
end
