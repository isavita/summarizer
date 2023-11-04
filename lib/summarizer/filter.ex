defmodule Summarizer.Filter do
  @allowed_extensions ~w(.py .js .jsx .ts .tsx .go .rb .java .cs .cpp .scss .sass .less .html .css .md .json .sh .xml .php .swift .kt .groovy .rs .ex .exs .elm .erl .hrl .lua .pl .pm .t .r .rmd .jl .c .h .m .mm .clj .cljs .cljc .hs .lhs .scala .sbt .d .dart .pas .prg .fp .aj .asm .bat .cmd .bash .fish .ps1 .vbs .rbw .vhd .vhdl .ucf .qsf .sdc .tcl .yml .yaml .ini .cfg .conf .toml .make .mk .dockerfile .v .sv .svh .uc .sls .slim .ejs .hbs .mustache .jade .pug .tpl .twig .liquid .haml .cfm)
  @specific_filenames ~w(Dockerfile Makefile)

  def filter_files(files) do
    Enum.filter(files, fn file ->
      check_extension(file) or check_specific_filename(file)
    end)
  end

  defp check_extension(file), do: Enum.any?(@allowed_extensions, &String.ends_with?(file, &1))
  defp check_specific_filename(file), do: file in @specific_filenames
end
