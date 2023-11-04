defmodule Summarizer.AnthropicHTTPClientTest do
  use ExUnit.Case

  alias Summarizer.AnthropicHTTPClient

  import Mox
  setup :verify_on_exit!

  describe "complete/1" do
    @success_resp %HTTPoison.Response{
      status_code: 200,
      body:
        "{\"completion\":\" Okay, let's solve this step-by-step:\\n42 + 0\\n= 42 (because adding 0 to any number gives the same number)\\nTherefore, 42 + 0 = 42\",\"log_id\":\"35ce\",\"model\":\"claude-2.0\",\"stop\":\"\\n\\nHuman:\",\"stop_reason\":\"stop_sequence\"}"
    }
    test "returns the completion" do
      expect(HTTPoison.BaseMock, :post!, fn url, payload, _headers, _opts ->
        assert url == "https://api.anthropic.com/v1/complete"
        assert String.contains?(payload, "claude-2")

        @success_resp
      end)

      message = "How much is 42 + 0?"
      assert {:ok, completion} = AnthropicHTTPClient.complete(message)
      assert " Okay, let's solve this step-by-step" <> _ = completion
    end
  end
end
