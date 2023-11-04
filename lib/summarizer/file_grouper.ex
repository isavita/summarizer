defmodule Summarizer.FileGrouper do
  defstruct files_contents: [], current_size: 0

  def map_files_to_structs(file_paths, char_limit \\ 400_000) do
    file_paths
    |> Enum.reduce({[], %__MODULE__{}}, fn file_path, {acc, current_struct} ->
      content = read_limited_lines(file_path)
      content_length = byte_size(content)

      if current_struct.current_size + content_length > char_limit do
        # If the current struct is empty, this is a large file that needs to be split
        if current_struct.current_size == 0 do
          {truncated_content, remaining_content} = split_content(content, char_limit)

          new_struct = %__MODULE__{
            files_contents: [{file_path, truncated_content}],
            current_size: byte_size(truncated_content)
          }

          # Start a new struct with the remaining content if any
          if remaining_content != "" do
            {[new_struct | acc],
             %__MODULE__{
               files_contents: [{file_path, remaining_content}],
               current_size: byte_size(remaining_content)
             }}
          else
            {[new_struct | acc], %__MODULE__{}}
          end
        else
          # Finalize the current struct and start a new one with the current content
          new_struct = %__MODULE__{files_contents: [{file_path, content}], current_size: content_length}
          {[current_struct | acc], new_struct}
        end
      else
        # Append content to the current struct
        updated_struct = update_struct(current_struct, file_path, content, content_length)
        {acc, updated_struct}
      end
    end)
    |> finalize_structs()
  end

  defp split_content(content, char_limit) do
    {content |> String.slice(0, char_limit),
     content |> String.slice(char_limit, byte_size(content))}
  end

  def read_limited_lines(file, line_limit \\ 2000) do
    try do
      file
      |> File.stream!()
      |> Enum.take(line_limit)
      |> Enum.join()
    rescue
      _ in [File.Error] -> ""
    end
  end

  defp update_struct(
         %__MODULE__{files_contents: files_contents, current_size: current_size} = struct,
         file_path,
         content,
         content_length
       ) do
    struct
    |> Map.put(:files_contents, files_contents ++ [{file_path, content}])
    |> Map.put(:current_size, current_size + content_length)
  end

  defp finalize_structs({acc, current_struct}) do
    acc
    |> Enum.reverse()
    |> List.insert_at(0, current_struct)
  end
end
