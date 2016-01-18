class AnalyzersController < ApplicationController
  def compare_recommendation_list
    rec_lists = Recommendation.find params[:list]
    rec_lists.each_with_index do |rec, idx|
      rec_lists.each_with_index do |comp_rec, comp_idx|
        if idx < comp_idx
          unless idx == comp_idx
            rec_source = rec.recommendation_sources.pluck(:source)
            comp_rec_source = comp_rec.recommendation_sources.pluck(:source)

            if rec_source.size == comp_rec_source.size
              puts "#{idx} <> #{comp_idx}: #{(rec_source & comp_rec_source).size.to_f / rec_source.size.to_f}"
            end
          end
        end
      end
    end
  end
end
