defmodule ElixirAssesmentServices.Categorizer do
  alias ElixirAssesment.Datasets.Post

  @non_meaningful_words ~w[a the in of on at if for to and or so as is are]

  @spec call(
          %ElixirAssesment.Datasets.Post{},
          %{optional(String.t()) => integer()}
        ) ::
          {
            :ok,
            %ElixirAssesment.Datasets.Post{}
          }
          | {:error, %Ecto.Changeset{}}
  def call(post, index) do
    match_in_index(index, words_list(post)) |> categorize(post)
  end

  @spec categorize([%{id: integer(), moderation: boolean()}], %ElixirAssesment.Datasets.Post{}) ::
          {
            :ok,
            %ElixirAssesment.Datasets.Post{}
          }
          | {:error, %Ecto.Changeset{}}
  defp categorize([], post) do
    Post.update_post(
      post,
      %{status: :published, published_at: DateTime.now!("Etc/UTC")}
    )
  end

  defp categorize(matched_categories, post) do
    category_ids = Enum.reduce(matched_categories, [], fn c, acc -> [c.id | acc] end)

    cond do
      Enum.any?(
        matched_categories,
        fn category -> category.moderation end
      ) ->
        Post.update_post_and_link_to_categories(
          post,
          %{status: :require_moderation},
          category_ids
        )

      true ->
        Post.update_post_and_link_to_categories(
          post,
          %{status: :published, published_at: DateTime.now!("Etc/UTC")},
          category_ids
        )
    end
  end

  @spec match_in_index(
          ElixirAssesmentServices.CategorizerProcess.index(),
          [String.t()]
        ) :: [%{id: integer(), moderation: boolean()}]
  defp match_in_index(index, words) do
    Map.take(index, words) |> Map.values()
  end

  @spec words_list(%ElixirAssesment.Datasets.Post{}) :: [String.t()]
  defp words_list(post) do
    "#{post.title} #{post.text}"
    |> String.split(~r/\W/, trim: true)
    |> Enum.map(&String.downcase/1)
    |> Enum.reject(fn word -> word in @non_meaningful_words end)
    |> Enum.uniq()
  end
end
