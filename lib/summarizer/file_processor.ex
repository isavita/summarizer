defmodule Summarizer.FileProcessor do
  @moduledoc false

  def read_limited_lines(file, line_limit \\ 2000) do
    try do
      file
      |> File.stream!()
      |> Enum.take(line_limit)
      |> Enum.join()
    rescue
      [File.Error] -> ""
    end
  end
end
