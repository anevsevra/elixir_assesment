defmodule ElixirAssesmentWeb.Api.V1.PostController do
  use ElixirAssesmentWeb, :controller

  def index(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{test: :test})
  end
end
