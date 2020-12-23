defmodule ElixirAssesmentServices.Categorizer do
  alias ElixirAssesment.Datasets

  @non_meaningful_words ~w[a the in of on at if for to and or so as is are]

  def call(post, index) do
    match_in_index(index, words_list(post)) |> categorize(post)
  end

  defp categorize([], post) do
    Datasets.update_post(
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
        Datasets.update_post_and_link_to_categories(
          post,
          %{status: :require_moderation},
          category_ids
        )

      true ->
        Datasets.update_post_and_link_to_categories(
          post,
          %{status: :published, published_at: DateTime.now!("Etc/UTC")},
          category_ids
        )
    end
  end

  defp match_in_index(index, words) do
    Enum.map(words, fn word -> index[word] end)
    |> Enum.reject(&is_nil/1)
  end

  defp words_list(post) do
    "#{post.title} #{post.text}"
    |> String.split(~r/\W/, trim: true)
    |> Enum.map(&String.downcase/1)
    |> Enum.reject(fn word -> word in @non_meaningful_words end)
    |> Enum.uniq()
  end
end
