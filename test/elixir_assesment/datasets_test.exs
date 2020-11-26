defmodule ElixirAssesment.DatasetsTest do
  use ElixirAssesment.DataCase

  alias ElixirAssesment.Datasets

  describe "categories" do
    alias ElixirAssesment.Datasets.Category

    @valid_attrs %{description: "some description", keywords: [], name: "some name", need_moderation: true, tag: "some tag"}
    @update_attrs %{description: "some updated description", keywords: [], name: "some updated name", need_moderation: false, tag: "some updated tag"}
    @invalid_attrs %{description: nil, keywords: nil, name: nil, need_moderation: nil, tag: nil}

    def category_fixture(attrs \\ %{}) do
      {:ok, category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Datasets.create_category()

      category
    end

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Datasets.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Datasets.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      assert {:ok, %Category{} = category} = Datasets.create_category(@valid_attrs)
      assert category.description == "some description"
      assert category.keywords == []
      assert category.name == "some name"
      assert category.need_moderation == true
      assert category.tag == "some tag"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Datasets.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      assert {:ok, %Category{} = category} = Datasets.update_category(category, @update_attrs)
      assert category.description == "some updated description"
      assert category.keywords == []
      assert category.name == "some updated name"
      assert category.need_moderation == false
      assert category.tag == "some updated tag"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Datasets.update_category(category, @invalid_attrs)
      assert category == Datasets.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Datasets.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Datasets.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Datasets.change_category(category)
    end
  end

  describe "posts" do
    alias ElixirAssesment.Datasets.Post

    @valid_attrs %{published_at: "2010-04-17T14:00:00Z", status: %{}, text: "some text", title: "some title"}
    @update_attrs %{published_at: "2011-05-18T15:01:01Z", status: %{}, text: "some updated text", title: "some updated title"}
    @invalid_attrs %{published_at: nil, status: nil, text: nil, title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Datasets.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Datasets.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Datasets.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Datasets.create_post(@valid_attrs)
      assert post.published_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert post.status == %{}
      assert post.text == "some text"
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Datasets.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Datasets.update_post(post, @update_attrs)
      assert post.published_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert post.status == %{}
      assert post.text == "some updated text"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Datasets.update_post(post, @invalid_attrs)
      assert post == Datasets.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Datasets.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Datasets.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Datasets.change_post(post)
    end
  end
end
