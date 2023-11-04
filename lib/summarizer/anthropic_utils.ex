defmodule Summarizer.AnthropicUtils do
  @moduledoc false

  @doc """
  Extracts the completion from the response body.

  Successful response:
  ```json
  {
    "completion": " Okay, let's solve this step-by-step:\n42 * 38\n= 42 * (30 + 8) \n= 42 * 30 + 42 * 8\n= 1260 + 336\n= 1596\n\nTherefore, 42 * 38 = 1596.",
    "stop_reason": "stop_sequence",
    "model": "claude-2.0",
    "stop": "\n\nHuman:",
    "log_id": "00c6b4ba97de04c5329dc50c0124e4814dfc3252d751afd55bcfaad44023be6d"
  }
  ```

  Error response:
  ```json
  {
    "error": {
      "type": "not_found_error",
      "message": "Not found"
    }
  }
  ```
  """
  @spec extract_complete(map()) :: binary()
  def extract_complete(body) do
    if body["stop"] == "\n\nHuman:" do
      body["completion"]
    else
      "NOT COMPLETED"
    end
  end
end
