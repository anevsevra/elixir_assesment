defmodule ElixirAssesmentWeb.PageController do
  use ElixirAssesmentWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
