class LotsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index]
  
  # GET /lots
  # GET /lots.json
  def index
    @lot_votes = Lot.find_with_reputation(:votes, :all, order: "votes desc")
    @all_lots = Lot.all.sum(&:appraised_value)
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
    @lots = @search.result.page(params[:page]).per(20)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties = @lots.order('appeal_value desc')

    @json = @lots.all.to_gmaps4rails do |lot, marker|
      marker.title  "#{lot.owner}"
      marker.json({ :id => lot.id })
    end
    
    
    @taxes_lost_chart = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph')
      chart.title('Commercial Taxes Lost to Appeal')
      chart.xAxis(categories: ['City Taxes lost on appeal', 'School Taxes lost on appeal', 'Total Taxes lost on appeal'])
      chart.yAxis(title: 'Dollars', min: 0)
      chart.series(name: 'Dollars', yAxis: 0, type: 'bar', data: [@city_commericial_tax_lost_to_appeal, @school_commericial_tax_lost_to_appeal, @total_commericial_tax_lost_to_appeal])
      chart.legend(enabled: false, align: 'left', verticalAlign: 'top', x: -10, y: 100, borderWidth: 0)
    end
    
    @taxes_by_zoning = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph2')
      chart.title('Commercial Taxes Paid to...')
      chart.xAxis(categories: ['City Taxes', 'School Taxes'])
      chart.yAxis(title: 'Dollars', min: 0)
      chart.series(name: 'Dollars', yAxis: 0, type: 'bar', data: [@city_commericial_tax_lost_to_appeal, @commericial_school_taxes_collected])
      chart.legend(enabled: false, verticalAlign: 'top', x: -10, y: 100, borderWidth: 0)
    end
    
    @taxes_by_type = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph3')
      chart.title('Taxes by property type')
      chart.series(name: 'Dollars', yAxis: 0, type: 'pie', data: [['Commercial',@commericial_taxable], ['Residential',@residential_taxable]])
      chart.legend(enabled: false, verticalAlign: 'top', x: -10, y: 100, borderWidth: 0, format: '<b>{chart.name}</b>: {chart.percentage:.1f} %')
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

    @lot_appeal = @lot.full_appeal
    @lot_appraised = @lot.appraised_value
    if @lot_appeal < @lot_appraised
      @lot_taxable =  @lot_appeal
    else
      @lot_taxable =  @lot_appraised
    end
    @lot_city_taxes_collected = (@lot_taxable * 0.01642)
    @lot_school_taxes_collected = (@lot_taxable * 0.0209)
    @lot_total_taxes_collected = (@lot_taxable * 0.03732)
    @lot_lost_to_appeal = (@lot.appraised_appraised - @lot_taxable)
    @city_lot_tax_lost_to_appeal = (@lot_lost_to_appeal * 0.01642)
    @school_lot_tax_lost_to_appeal = (@lot_lost_to_appeal * 0.0209)

    @total_lot_tax_appraised = (@lot_appraised * 0.03732)
    @total_lot_tax_appeal = (@lot_taxable * 0.03732)
    
    @total_lot_tax_lost_to_appeal = (@total_lot_tax_appraised - @total_lot_tax_appeal)

    @json = @lot.to_gmaps4rails do |lot, marker|
      marker.title   "#{lot.owner}"
      marker.json({ :id => lot.id })
    end
    if user_signed_in?
      @search = Lot.search(params[:q])
    else
      @search = Lot.commercial_property.search(params[:q])
    end
    @properties = @search.result.page(params[:page]).per(15).near(@lot.property_map_address, 10, order: :distance)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?

    @taxes_by_type = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph3')
      chart.title('')
      chart.series(name: 'Dollars', yAxis: 0, type: 'pie', data: [['City Taxes',@lot_city_taxes_collected], ['School Taxes',@lot_school_taxes_collected]])
      chart.legend(enabled: false, verticalAlign: 'top', x: -10, y: 100, borderWidth: 0, format: '<b>{chart.name}</b>: {chart.percentage:.1f} %')
    end

    @taxes_lost_chart = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph')
      chart.title('')
      chart.xAxis(categories: ['City Taxes lost on appeal', 'School Taxes lost on appeal', 'Total Taxes lost on appeal'])
      chart.yAxis(title: 'Dollars', min: 0)
      chart.series(name: 'Dollars', yAxis: 0, type: 'bar', data: [@city_lot_tax_lost_to_appeal, @school_lot_tax_lost_to_appeal, @total_lot_tax_lost_to_appeal])
      chart.legend(enabled: false, align: 'left', verticalAlign: 'top', x: -10, y: 100, borderWidth: 0)
    end


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lot }
    end
  end
end



