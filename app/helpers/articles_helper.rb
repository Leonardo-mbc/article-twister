module ArticlesHelper
  def fetch_body(id)
    body = ""
    body = File.open("#{Rails.root}/public/articles_raw/#{id}.txt", 'r').read
    body
  end
end
