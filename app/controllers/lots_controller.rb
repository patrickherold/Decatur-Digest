class LotsController < ApplicationController
  # GET /lots
  # GET /lots.json
  def index
    @lot_votes = Lot.find_with_reputation(:votes, :all, order: "votes desc")
    

    
    @search = Lot.search(params[:q])
    @lots = @search.result.page(params[:page]).per(20)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties = @lots.order('taxable desc')
    

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
    
    @search = Lot.search(params[:q])
    @properties = @search.result.page(params[:page]).per(15).near(@lot.property_map_address, 10, order: :distance)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lot }
    end
  end
end



