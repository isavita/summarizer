defmodule Summarizer.FilterTest do
  use ExUnit.Case

  describe "filter_files/1" do
    test "includes files with a wide range of whitelisted extensions" do
      files = [
        "app.py",
        "sql.dump",
        "component.jsx",
        "util.ts",
        "style.scss",
        "document.md",
        "config.json",
        "script.sh",
        "README.md",
        "Dockerfile",
        "ignore.gitignore",
        "template.html",
        "style.css",
        "webpack.config.js",
        "image.png",
        "archive.zip"
      ]

      expected_files = [
        "app.py",
        "component.jsx",
        "util.ts",
        "style.scss",
        "document.md",
        "config.json",
        "script.sh",
        "README.md",
        "Dockerfile",
        "template.html",
        "style.css",
        "webpack.config.js"
      ]

      assert Summarizer.Filter.filter_files(files) == expected_files
    end
  end
end
