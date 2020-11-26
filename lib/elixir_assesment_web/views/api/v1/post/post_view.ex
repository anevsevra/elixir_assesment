defmodule ElixirAssesmentWeb.Api.V1.PostView do
  use ElixirAssesmentWeb, :view

  def render("index.json", %{posts: posts}) do
    %{
      data: %{
        posts:
          render_many(posts, __MODULE__, "post.json")
      }
    }
  end

  def render("show.json", %{post: post}) do
    %{
      data: render_one(post, __MODULE__, "post.json")
    }
  end

  def render("post.json", %{post: post}) do
    %{
      post: %{
        id: post.id,
        title: post.title,
        text: post.text,
        status: post.status,
        published_at: post.published_at,
        inserted_at: post.inserted_at,
        updated_at: post.updated_at
      }
    }
  end
end
