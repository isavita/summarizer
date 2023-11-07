defmodule Summarizer.Filetree do
  @default_opts [files_only: false]

  def generate_file_tree(root_path, opts \\ []) do
    options = Keyword.merge(@default_opts, opts)

    root_path
    |> traverse_directory(options)
    |> Enum.sort()
  end

  defp traverse_directory(current_path, opts) do
    File.ls(current_path)
    |> case do
      {:ok, entries} ->
        Enum.flat_map(entries, &process_entry(&1, current_path, opts))

      {:error, _} ->
        []
    end
  end

  defp process_entry(entry, current_path, opts) do
    full_path = Path.join([current_path, entry])

    File.stat(full_path)
    |> case do
      {:ok, %File.Stat{type: :directory}} ->
        traverse = traverse_directory(full_path, opts)
        if opts[:files_only], do: traverse, else: [full_path <> "/" | traverse]

      {:ok, %File.Stat{type: :regular}} ->
        [full_path]

      _ ->
        []
    end
  end
end
