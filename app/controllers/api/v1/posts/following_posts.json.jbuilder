json.pagination do
  json.extract! @pagination, :prev_url, :next_url, :count, :page, :next
end

json.data do
  json.array! @posts, partial: "api/v1/posts/post", as: :post
end
