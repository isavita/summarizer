defmodule SummarizerWeb.PageControllerTest do
  use SummarizerWeb.ConnCase

  describe "catch-all route" do
    test "returns 404 not found for random path", %{conn: conn} do
      conn = get(conn, "/some/random/path")
      assert conn.status == 404
      assert conn.resp_body == "Not Found"
    end
  end
end
