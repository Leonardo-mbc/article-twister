class AnalyzersController < ApplicationController
  def compare_recommendation_list
    rec_lists = Recommendation.find params[:list]

    result = []
    rec_lists.each_with_index do |rec, idx|
      rec_lists.each_with_index do |comp_rec, comp_idx|

        if idx < comp_idx
          unless idx == comp_idx
            rec_source = rec.recommendation_sources.pluck(:source)
            comp_rec_source = comp_rec.recommendation_sources.pluck(:source)

            if rec_source.size == comp_rec_source.size
              nps = Hash.new
              nps_ary = Hash.new
              sign = Hash.new
              sign_ary = Hash.new
              known = Hash.new
              known_ary = Hash.new
              known_ids = Hash.new
              srdp = Hash.new

              nps["#{rec.id}"] = []
              nps_ary["#{rec.id}"] = []
              sign["#{rec.id}"] = []
              sign_ary["#{rec.id}"] = []
              known["#{rec.id}"] = []
              known_ary["#{rec.id}"] = []
              known_ids["#{rec.id}"] = []
              srdp["#{rec.id}"] = []

              nps["#{comp_rec.id}"] = []
              nps_ary["#{comp_rec.id}"] = []
              sign["#{comp_rec.id}"] = []
              sign_ary["#{comp_rec.id}"] = []
              known["#{comp_rec.id}"] = []
              known_ary["#{comp_rec.id}"] = []
              known_ids["#{comp_rec.id}"] = []
              srdp["#{comp_rec.id}"] = []


              unexp = 1.0 - (rec_source & comp_rec_source).size.to_f / rec_source.size.to_f

              News.where(news_id: rec_source).each do |news|
                nps_ary["#{rec.id}"].push news.nps(current_user)
                sign_ary["#{rec.id}"].push news.sign(current_user)

                knw = news.known(current_user)
                known_ary["#{rec.id}"].push knw
                known_ids["#{rec.id}"].push news.news_id unless knw
              end

              pstv = nps_ary["#{rec.id}"].select {|i| 9 <= i.to_i }
              ngtv = nps_ary["#{rec.id}"].select {|i| i.to_i <= 6 }
              nps["#{rec.id}"] = (pstv.size.to_f / nps_ary["#{rec.id}"].size.to_f - ngtv.size.to_f / nps_ary["#{rec.id}"].size.to_f)

              pstv = sign_ary["#{rec.id}"].select {|i| 0 < i.to_i }
              sign["#{rec.id}"] = (pstv.size.to_f / sign_ary["#{rec.id}"].size.to_f)

              pstv = known_ary["#{rec.id}"].select {|i| !i }
              known["#{rec.id}"] = (pstv.size.to_f / known_ary["#{rec.id}"].size.to_f)
              srdp["#{rec.id}"] = ((rec_source - comp_rec_source) & known_ids["#{rec.id}"]).size

              News.where(news_id: comp_rec_source).each do |news|
                nps_ary["#{comp_rec.id}"].push news.nps(current_user)
                sign_ary["#{comp_rec.id}"].push news.sign(current_user)

                knw = news.known(current_user)
                known_ary["#{comp_rec.id}"].push knw
                known_ids["#{comp_rec.id}"].push news.news_id unless knw
              end

              pstv = nps_ary["#{comp_rec.id}"].select {|i| 9 <= i.to_i }
              ngtv = nps_ary["#{comp_rec.id}"].select {|i| i.to_i <= 6 }
              nps["#{comp_rec.id}"] = (pstv.size.to_f / nps_ary["#{rec.id}"].size.to_f - ngtv.size.to_f / nps_ary["#{rec.id}"].size.to_f)

              pstv = sign_ary["#{comp_rec.id}"].select {|i| 0 < i.to_i }
              sign["#{comp_rec.id}"] = (pstv.size.to_f / sign_ary["#{rec.id}"].size.to_f)

              pstv = known_ary["#{comp_rec.id}"].select {|i| !i }
              known["#{comp_rec.id}"] = (pstv.size.to_f / known_ary["#{comp_rec.id}"].size.to_f)
              srdp["#{comp_rec.id}"] = ((comp_rec_source - rec_source) & known_ids["#{comp_rec.id}"]).size

              logger.fatal "expr: #{(comp_rec_source - rec_source)}"
              logger.fatal "known: #{known_ids["#{comp_rec.id}"]}"

              result.push({ compare: "#{rec_lists[idx].id},#{rec_lists[comp_idx].id}", unexp: unexp, nps: nps, precision: sign, novelty: known, serendipity: srdp })
            end
          end
        end

      end
    end

    render json: result.to_json
  end
end
