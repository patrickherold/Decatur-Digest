class LotsController < ApplicationController
  # GET /lots
  # GET /lots.json
  def index
    @lot_votes = Lot.find_with_reputation(:votes, :all, order: "votes desc")
    @all_lots = Lot.all.sum(&:appraised_value)
    @commericial_appeal = Lot.all_commericial_appeal.sum(&:appeal_value)
    @commericial_appraised = Lot.all_commericial_appraised.sum(&:appraised_value)
    @commericial_digest = Lot.commercial_property.sum(&:appraised_value)
    @commericial_taxable = (@commericial_appeal + @commericial_appraised)
    @commericial_lost_to_appeal = (@commericial_digest - @commericial_taxable)
    @city_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.01642)
    @school_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.0209)
    @total_commericial_tax_lost_to_appeal = (@city_commericial_tax_lost_to_appeal + @school_commericial_tax_lost_to_appeal)
    @search = Lot.commercial_property.search(params[:q])
    @lots = @search.result.page(params[:page]).per(20)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties = @lots.order('appeal_value desc')

    @json = @lots.all.to_gmaps4rails do |lot, marker|
      marker.title  "#{lot.owner}"
      marker.json({ :id => lot.id })
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lots }
    end
  end


  def vote
    value = params[:type] == "just_right" ? 0 : value = params[:type] == "up" ? 1 : -1
    @lot_votes = Lot.find(params[:id])
    @lot_votes.add_or_update_evaluation(:votes, value, current_user)
    redirect_to :back, notice: "Thank you for voting"
  end



  def show
    @lot = Lot.find(params[:id])

    @json = @lot.to_gmaps4rails do |lot, marker|
      marker.title   "#{lot.owner}"
      marker.json({ :id => lot.id })
    end
    
    @search = Lot.commercial_property.search(params[:q])
    @properties = @search.result.page(params[:page]).per(15).near(@lot.property_map_address, 10, order: :distance)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lot }
    end
  end
end



