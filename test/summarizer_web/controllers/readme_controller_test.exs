defmodule SummarizerWeb.ReadmeControllerTest do
  use SummarizerWeb.ConnCase

  import Mox
  setup :verify_on_exit!

  @identify_important_success_resp %HTTPoison.Response{
    status_code: 200,
    body:
      "{\"completion\":\" Here are the most important files to understand the summarizer project:\\n\\n<Files>\\n<File>/Users/isavita/git/summarizer/README.md</File>\\n<File>/Users/isavita/git/summarizer/lib/summarizer.ex</File>  \\n<File>/Users/isavita/git/summarizer/lib/summarizer_web/controllers/page_controller.ex</File>\\n<File>/Users/isavita/git/summarizer/lib/summarizer_web/router.ex</File>\\n</Files>\\n\\nThe README provides an overview of the project and what it does. \\n\\nThe main summarizer.ex contains the core logic for generating summaries.\\n\\nThe page_controller handles the API endpoints for summarization.\\n\\nThe router routes requests to the appropriate controller actions.\\n\\nReading these files should give a good understanding of the overall project structure and how to use the summarization API.\",\"stop_reason\":\"stop_sequence\",\"model\":\"claude-2.0\",\"stop\":\"\\n\\nHuman:\",\"log_id\":\"bf60c98897c302ac142824eff9d2642d1865252ec78857d087d1eb1034a5a5aa\"}"
  }

  @summarize_project_success_resp %HTTPoison.Response{
    status_code: 200,
    body:
      "{\"completion\":\" <FileSummaries>\\n  <FileSummary>\\n    <File>/Users/isavita/git/summarizer/README.md</File>\\n    <Summary>This README file provides an overview of a Phoenix web application that generates README files by summarizing codebases. It describes the main logic in summarizer.ex, utility modules, page and router controllers, and API and dev routes.</Summary>\\n  </FileSummary>\\n  \\n  <FileSummary>\\n    <File>/Users/isavita/git/summarizer/lib/summarizer.ex</File>\\n    <Summary>This Elixir module contains the main logic for summarizing code files to generate READMEs. It identifies important files, summarizes file groups, combines summaries, and validates output using utility modules and the Anthropic HTTP client.</Summary>\\n  </FileSummary>\\n\\n  <FileSummary>\\n    <File>/Users/isavita/git/summarizer/lib/summarizer_web/controllers/page_controller.ex</File>\\n    <Summary>This Elixir controller handles rendering 404 \\\"Not Found\\\" pages.</Summary>\\n  </FileSummary>\\n\\n  <FileSummary>\\n    <File>/Users/isavita/git/summarizer/lib/summarizer_web/router.ex</File>\\n    <Summary>This Elixir router defines the application's API, dev, health check, and 404 catch-all routes.</Summary>\\n  </FileSummary>\\n\\n</FileSummaries>\",\"stop_reason\":\"stop_sequence\",\"model\":\"claude-2.0\",\"stop\":\"\\n\\nHuman:\",\"log_id\":\"822da24cb0477f324c88f4af85ea01d0faea3c5d0bcca3dab7a8b5f91889d1e6\"}"
  }

  @summarize_text_to_readme_success_resp %HTTPoison.Response{
    status_code: 200,
    body:
      "{\"completion\":\" <ReadmeFile>\\n\\n# Summarizer\\n\\nThis Phoenix web application generates README files by summarizing codebases. The main logic for summarizing files is in `summarizer.ex`. It identifies important files, summarizes file groups, combines summaries, and validates output using utility modules and the Anthropic HTTP client. \\n\\nThe `page_controller.ex` handles rendering 404 pages. The router defines the application's API, dev, health check, and 404 catch-all routes.\\n\\n</ReadmeFile>\",\"stop_reason\":\"stop_sequence\",\"model\":\"claude-2.0\",\"stop\":\"\\n\\nHuman:\",\"log_id\":\"e5adfd3702d8598aca8a49e0e09436261f692c97406156018bb351b0a1569e81\"}"
  }

  test "POST /api/generate_readme", %{conn: conn} do
    expect(HTTPoison.BaseMock, :post!, fn _url,
                                          "{\"max_tokens_to_sample\":99000," <> _payload,
                                          _headers,
                                          _opts ->
      @identify_important_success_resp
    end)

    expect(HTTPoison.BaseMock, :post!, fn _url,
                                          "{\"max_tokens_to_sample\":95000,\"model\":\"claude-2\",\"prompt\":\"\\n\\nHuman:\\n<FileContents>" <>
                                            _payload,
                                          _headers,
                                          _opts ->
      @summarize_project_success_resp
    end)

    expect(HTTPoison.BaseMock, :post!, fn _url,
                                          "{\"max_tokens_to_sample\":95000,\"model\":\"claude-2\",\"prompt\":\"\\n\\nHuman:\\n <FileSummaries" <>
                                            _payload,
                                          _headers,
                                          _opts ->
      @summarize_text_to_readme_success_resp
    end)

    conn = post(conn, "/api/generate_readme", %{url: "https://github.com/isavita/summarizer"})
    assert json_response(conn, 200)["data"]
  end
end
