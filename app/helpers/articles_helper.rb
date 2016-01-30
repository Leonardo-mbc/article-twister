module ArticlesHelper
  def header_sign(sign)
    sign_patterns = { -1 => "panel-danger", 0 => "panel-info", 1 => "panel-success" }
    sign_patterns[sign.to_i]
  end

  def tr_sign(sign)
    sign_patterns = { -1 => "danger", 0 => "info", 1 => "success" }
    sign_patterns[sign.to_i]
  end

  def fetch_body(id)
    body = ""

    begin
      body = File.open("#{Rails.root}/public/articles_raw/#{id}.txt", 'r').read
    rescue => e
      p e
    end

    body
  end

  def time_notice(checked_at)
    t = checked_at.to_s.split(/\s/)
    ["<span class='time_notice'>#{t[1]}</span>　", t.first].join
  end
end
