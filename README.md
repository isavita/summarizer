# Summarizer

This Phoenix web application generates README files by summarizing codebases. The main logic for summarizing files is in `summarizer.ex`. It identifies important files, summarizes file groups, combines summaries, and validates output using utility modules and the Anthropic HTTP client. 

The `page_controller.ex` handles rendering 404 pages. The router defines the application's API, dev, health check, and 404 catch-all routes.
