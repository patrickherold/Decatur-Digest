class MapController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter { @main_nav = :lots }

  # GET /lots
  # GET /lots.json
  def index
    @all_lots = Lot.sum('appraised_value') #all.sum(&:appraised_value)
    @commericial_appeal = Lot.all_commericial_appeal.sum(&:full_appeal)
    @commericial_appraised = Lot.all_commericial_appraised.sum(&:appraised_value)
    @commericial_digest = Lot.commercial_property.sum(&:appraised_value)
    @commericial_taxable = (@commericial_appeal + @commericial_appraised)
    @residential_taxable = (@all_lots - @commericial_taxable)
    @commericial_city_taxes_collected = (@commericial_taxable * 0.01642)
    @commericial_school_taxes_collected = (@commericial_taxable * 0.0209)
    @commericial_lost_to_appeal = (@commericial_digest - @commericial_taxable)
    @city_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.01642)
    @school_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.0209)
    @total_commericial_tax_lost_to_appeal = (@city_commericial_tax_lost_to_appeal + @school_commericial_tax_lost_to_appeal)
    if user_signed_in?
      @search = Lot.search(params[:q])
    else
      @search = Lot.commercial_property.search(params[:q])
    end
    @lots = @search.result.page(params[:page]).per(100)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties = @lots.order('appraised_value desc')
    @properties_for_workflow = @search.result

    @json = @lots.all.to_gmaps4rails do |lot, marker|
      marker.title "#{lot.owner}"
      marker.json({ :id => lot.id })
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lots }
    end

  end
end



