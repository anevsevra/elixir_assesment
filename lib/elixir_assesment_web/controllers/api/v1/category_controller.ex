defmodule ElixirAssesmentWeb.Api.V1.CategoryController do
  use ElixirAssesmentWeb, :controller

  def index(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{})
  end

  def show(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{})
  end

  def create(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{})
  end

  def delete(conn, _) do
    conn
    |> put_status(:ok)
    |> json(%{})
  end
end
