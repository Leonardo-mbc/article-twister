module WordProcessor
  extend ActiveSupport::Concern

  def wc_hash(news_id)
    public_dir = "#{Rails.root}/public"

    article_wc = []
    art = File.open("#{public_dir}/articles_wc/#{news_id}.txt", 'r').read
    art.split("\n").each do |line|
      wc = line.split(',')
      article_wc.push({ :word => wc[0], :count => wc[1].to_i })
    end

    article_wc
  end

  def save_article(body, id, dir)
    public_dir = "#{Rails.root}/public"

    case dir
      when 'raw'
        f = File.open("#{public_dir}/articles_raw/#{id}.txt", 'w')
        f.puts body
        f.close

      when 'wc'
        f = File.open("#{public_dir}/articles_wc/#{id}.txt", 'w')
        body.each do |w, c|
          f.puts "#{w},#{c}"
        end
        f.close

      when 'prof'
        f = File.open("#{public_dir}/profiles/#{id}.txt", 'w')
        body.each do |w, c|
          f.puts "#{w},#{c}"
        end
        f.close

      when 'user_prof'
        f = File.open("#{public_dir}/user_profiles/#{id}.txt", 'w')
        body.each do |w, c|
          f.puts "#{w},#{c}"
        end
        f.close
    end
  end

end
