class ArticlesController < ApplicationController
  include WordProcessor

  def index
    @news = News.all().order("created_at DESC").page(params[:page]).per(10)
    @sign_patterns = {-1 => "panel-danger", 0 => "panel-info", 1 => "panel-success"}
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
    @news = News.all().order("created_at DESC").page params[:page]
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
      arts = JSON.parse open("#{Settings.api.host}/api/v1/?topic_id=#{topic}").read
      arts['news'].each do |art|
        unless art['body'].nil? || News.exists?(news_id: art['id'])
          @articles.push art
        end
        proced_id.push art['id']
      end
    end

    news.each do |news_id|
      unless proced_id.include? news_id
        arts = JSON.parse open("#{Settings.api.host}/api/v1/?news_id=#{news_id}").read
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

private
  def similar(prof_id)
    public_dir = "#{Rails.root}/public"
    sim_box = Hash.new
    Dir::glob("#{public_dir}/articles_wc/*.txt").each do |data|
      Open3.popen3("#{Rails.root}/app/bin/similar #{public_dir}/profiles/#{prof_id}.txt #{data}") do |stdin, stdout, stderr|
        stdin.close
        sim = stdout.read.to_f
        id = data.scan(/([0-9]+?)\.txt/).flatten.first
        sim_box[id] = sim
      end
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
