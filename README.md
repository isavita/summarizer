# ![Phoenix Codebase README Generator Logo](./priv/static/summarizer_logo.png)

This Elixir application generates README files by summarizing codebases. 

## Overview

The application is built using the Phoenix web framework. The main logic for generating summaries is in `summarizer.ex`. It identifies important files, groups and summarizes them, combines the summaries, and validates the output. 

The `page_controller.ex` handles 404 pages. The `router.ex` defines the API routes. 

## Usage

To use the application:

1. Start the Phoenix server with `mix phx.server`
2. Make a POST request to `/api/summarize` with a JSON body containing the file paths and contents to summarize
3. The response will contain the generated README content

The `summarizer.ex` module contains the key logic:

- `identify_important_files/1` - Finds config, lib, test etc files 
- `group_and_summarize_files/1` - Groups and summarizes files
- `combine_summaries/1` - Combines file summaries into overall summary
- `validate_output/1` - Validates the generated README

The `Anthropic` HTTP client is used to call the Anthropic API for summarization.

## Configuration

The `mix.exs` file defines dependencies, environment configuration and build tasks.

## Contributing

Pull requests are welcome to improve summarization and add new features.
