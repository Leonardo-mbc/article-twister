class ArticlesController < ApplicationController
  include WordProcessor

  def index
    @news = News.all().order("created_at DESC").page(params[:page]).per(10)
  end

  def picker
  end

  def tuner
    @selectors = [
      { label_type: 'primary', axis: 'X' },
      { label_type: 'success', axis: 'Y' }
    ]

    @profiles = Profile.all
  end

  def imported_list
    @news = News.all().order("created_at DESC")
  end

  def x_similar
    prof_id = params[:id]
    @sim_box = similar prof_id
  end

  def y_similar
    prof_id = params[:id]
    @sim_box = similar prof_id
  end

  def import
    news = []
    topics = []

    news = params[:selected]["news"].map{ |id| id.to_i } unless params[:selected]["news"].nil?
    topics = params[:selected]["topics"] unless params[:selected]["topics"].nil?

    @articles = []
    proced_id = []

    topics.each do |topic|
      arts = JSON.parse open("#{Settings.api.rails_host}/api/v1/?topic_id=#{topic}").read
      arts['news'].each do |art|
        unless art['body'].nil? || News.exists?(news_id: art['id'])
          @articles.push art
        end
        proced_id.push art['id']
      end
    end

    news.each do |news_id|
      unless proced_id.include? news_id
        arts = JSON.parse open("#{Settings.api.rails_host}/api/v1/?news_id=#{news_id}").read
        arts['news'].each do |art|
          unless art['body'].nil? || News.exists?(news_id: art['id'])
            @articles.push art
          end
        end
      end
    end

    @articles.each do |art|
      save_article art['body'], art['id'], 'raw'
      save_article word_count(art['body']), art['id'], 'wc'

      news = News.new
      news.news_id = art['id']
      news.topic_id = art['topic_id']
      news.title = art['title']
      news.source = art['source']
      news.url = art['url']
      news.host = art['host']
      news.save
    end

    save_corpusDF()

  end

  def combine
    unless params[:selected].nil?
      news = params[:selected].map{|id| id.to_i }
      @total_wc = Hash.new(0)

      news.each do |news_id|
        wc_hash(news_id).each do |wc|
          @total_wc[wc[:word]] += wc[:count]
        end
      end

      # TODO: 関連付けのままsaveしたい
      prof = Profile.create({ name: params[:name], profile: @total_wc.to_param })
      news.each do |news_id|
        ps = ProfileSource.create({ profile_id: prof.id, source: news_id })
      end

      save_article @total_wc, prof.id, 'prof' if prof.present?
    end
  end

  def push_rate
    news_id = params[:news_id]
    sign = params[:sign]
    user_id = current_user.id

    news = News.where(news_id: news_id).first
    if news.sign(user_id).nil?
      rate = UserDiscrimination.new
    else
      rate = news.user_discriminations.where(user_id: user_id).first
    end

    rate.news = news
    rate.sign = sign
    rate.user = current_user
    status = rate.save

    checked = UserDiscrimination.where(user_id: user_id).count
    render json: { status: status,  checked: checked }
  end

  def clustering
    trash_dir = "#{Rails.root}/tmp/cluster_trash"
    wc_dir = "#{Rails.root}/public/articles_wc"
    filename = params[:filename]
    divide = params[:div]
    label_quant = params[:label_quant]

    f = File.open("#{trash_dir}/#{filename}.txt", 'w')
    params[:map].each do |item_ary|
      item = item_ary.second
      f.puts [item[:news_id], item[:x], item[:y]].join(',')
    end
    f.close

    stdout = `#{Rails.root}/app/bin/k-means++ #{trash_dir}/#{filename}.txt #{divide} 2> #{trash_dir}/c#{filename}.txt`
    clustered = stdout.split('$')
    stdout = `#{Rails.root}/app/bin/cluster_tf #{trash_dir}/c#{filename}.txt #{wc_dir}/ #{label_quant}`
    label = stdout.split('$')

    @gravities = clustered.first.split("\n").map{|l| l.split(',')}.reject(&:blank?)
    @clusters = clustered.second.split("\n").map{|l| l.split(',')}.reject(&:blank?)
    @glabel = label.map{|l| l.split("\n").reject(&:blank?)}
  end

  def recommend
    trash_dir = "#{Rails.root}/tmp/cluster_trash"
    user_data = { x: params[:user_x].to_f, y: params[:user_y].to_f }
    recommend_list = {}
    quant = params[:quant].to_i

    file = File.open("#{trash_dir}/#{params[:filename]}.txt", 'r').read
    file.each_line do |line|
      d = line.split(',')
      x = (user_data[:x] - d[1].to_f) ** 2
      y = (user_data[:y] - d[2].to_f) ** 2
      recommend_list[d[0]] =  Math.sqrt(x + y)
    end

    ranking = recommend_list.sort {|(k1, v1), (k2, v2)| v1 <=> v2 }


    recommend_list = []
    ranking[0..(quant - 1)].each do |doc|
      recommend_list.push doc.first.to_i
    end

    articles = News.where(news_id: recommend_list)
    render :partial => "article", :locals => { articles: articles }
  end

private
  def similar(prof_id)
    public_dir = "#{Rails.root}/public"
    sim_box = Hash.new

    checked_articles = current_user.user_discriminations.map{|c| c.news.news_id }

    if prof_id == '0'
      base_prof = "#{public_dir}/user_profiles/#{current_user.id}.txt"
    else
      base_prof = "#{public_dir}/profiles/#{prof_id}.txt"
    end

    Dir::glob("#{public_dir}/articles_wc/*.txt").each do |data|
      doc_id = data.scan(/([0-9]+?)\.txt/).flatten.first.to_i
      unless checked_articles.include?(doc_id)
        Open3.popen3("#{Rails.root}/app/bin/similar #{base_prof} #{data}") do |stdin, stdout, stderr|
          stdin.close
          sim = stdout.read.to_f
          id = data.scan(/([0-9]+?)\.txt/).flatten.first
          sim_box[id] = sim
        end
      end
    end

    Open3.popen3("#{Rails.root}/app/bin/similar #{base_prof} #{public_dir}/user_profiles/#{current_user.id}.txt") do |stdin, stdout, stderr|
      stdin.close
      sim = stdout.read.to_f
      sim_box['user'] = sim
    end

    sim_box
  end

  def word_count(text)
    wc = Hash.new 0
    Natto::MeCab.new().parse(text).split("\n").each do |word|
      sep_w = word.split("\t")
      features = sep_w.last.split(",")
      wc[sep_w.first] += 1 if features[0] == "名詞" && features[1] == "一般"
    end

    return wc

    #spawn "./count #{public_dir}/articles_raw/#{art[:id]}.txt > #{public_dir}/articles/#{art[:id]}.txt", :chdir => "#{Rails.root}/app/bin"
  end
end
