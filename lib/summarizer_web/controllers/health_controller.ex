defmodule SummarizerWeb.HealthController do
  use SummarizerWeb, :controller

  def index(conn, _params) do
    text(conn, "OK")
  end
end
