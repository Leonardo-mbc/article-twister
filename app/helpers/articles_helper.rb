module ArticlesHelper
  def header_sign(sign)
    sign_patterns = { -1 => "panel-danger", 0 => "panel-info", 1 => "panel-success" }
    sign_patterns[sign.to_i]
  end

  def fetch_body(id)
    body = ""
    body = File.open("#{Rails.root}/public/articles_raw/#{id}.txt", 'r').read
    body
  end

  def time_notice(checked_at)
    t = checked_at.to_s.split(/\s/)
    ["<span class='time_notice'>#{t[1]}</span>　", t.first].join
  end
end
