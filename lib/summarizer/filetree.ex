defmodule Summarizer.Filetree do
  @default_opts [files_only: false]

  def generate_file_tree(root_path, opts \\ []) do
    options = Keyword.merge(@default_opts, opts)

    traverse_directory(root_path, options)
    |> Enum.sort()
  end

  defp traverse_directory(current_path, opts) do
    case File.ls(current_path) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(fn entry ->
          full_path = Path.join(current_path, entry)

          case File.stat(full_path) do
            {:ok, %File.Stat{type: :directory}} ->
              if opts[:files_only] do
                traverse_directory(full_path, opts)
              else
                [full_path | traverse_directory(full_path, opts)]
              end

            {:ok, %File.Stat{type: :regular}} ->
              [full_path]

            _ ->
              []
          end
        end)

      {:error, _} ->
        []
    end
  end
end
