class LotsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter { @main_nav = :lots }

  # GET /lots
  # GET /lots.json
  def index
    # @lot_votes = Lot.find_with_reputation(:votes, :all, order: "votes desc")
    @all_lots = Lot.latest.sum('appraised_value') #all.sum(&:appraised_value)
    @commericial_appeal = Lot.latest.all_commericial_appeal.sum(&:full_appeal)
    @commericial_appraised = Lot.latest.all_commericial_appraised.sum(&:appraised_value)
    @commericial_digest = Lot.latest.commercial_property.sum(&:appraised_value)
    @commericial_taxable = (@commericial_appeal + @commericial_appraised)
    @residential_taxable = (@all_lots - @commericial_taxable)
    @commericial_city_taxes_collected = (@commericial_taxable * 0.01642)
    @commericial_school_taxes_collected = (@commericial_taxable * 0.0209)
    @commericial_lost_to_appeal = (@commericial_digest - @commericial_taxable)
    @city_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.01642)
    @school_commericial_tax_lost_to_appeal = (@commericial_lost_to_appeal * 0.0209)
    @total_commericial_tax_lost_to_appeal = (@city_commericial_tax_lost_to_appeal + @school_commericial_tax_lost_to_appeal)
    if user_signed_in?
      @search = Lot.latest.search(params[:q])
    else
      @search = Lot.latest.commercial_property.search(params[:q])
    end
    @lots = @search.result.page(params[:page]).per(20)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties = @lots.order('appraised_value desc')
    organizations = Organization.all # preload cache
    @properties_for_workflow = current_user ? @search.result.select { |l|
      organizations.include?(l.organization_id) && l.organization_id == current_user.organization_id
    } : []

    @json = @lots.all.to_gmaps4rails do |lot, marker|
      marker.title "#{lot.owner}"
      marker.json({ :id => lot.id })
    end

    @taxes_lost_chart = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph')
      chart.title('Commercial Taxes Suspended during Appeal')
      chart.xAxis(categories: ['City Taxes lost on appeal', 'School Taxes lost on appeal', 'Total Taxes lost on appeal'])
      chart.yAxis(title: 'Dollars', min: 0)
      chart.series(name: 'Dollars', yAxis: 0, type: 'bar', data: [@city_commericial_tax_lost_to_appeal, @school_commericial_tax_lost_to_appeal, @total_commericial_tax_lost_to_appeal])
      chart.legend(enabled: false, align: 'left', verticalAlign: 'top', x: -10, y: 100, borderWidth: 0)
      chart.credits(0)
    end

    @taxes_by_zoning = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph2')
      chart.title('Commercial Taxes Paid to...')
      chart.xAxis(categories: ['City Taxes', 'School Taxes'])
      chart.yAxis(title: 'Dollars', min: 0)
      chart.series(name: 'Dollars', yAxis: 0, type: 'bar', data: [@city_commericial_tax_lost_to_appeal, @commericial_school_taxes_collected])
      chart.legend(enabled: false, verticalAlign: 'top', x: -10, y: 100, borderWidth: 0)
      chart.credits(0)
    end

    @taxes_by_type = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph3')
      chart.title('Taxes by property type')
      chart.series(name: 'Dollars', yAxis: 0, type: 'pie', data: [['Commercial', @commericial_taxable], ['Residential', @residential_taxable]])
      chart.legend(enabled: false, verticalAlign: 'top', x: -10, y: 100, borderWidth: 0, format: '<b>{chart.name}</b>: {chart.percentage:.1f} %')
      chart.credits(0)
    end

    @properties_value_trend = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph31')
      chart.title('Properties Value Trend')
      chart.yAxis(title: 'Dollars', min: 0)
      stats = {}
      Lot.select('DISTINCT tax_year').map(&:tax_year).each { |year|
        stats[year] = {
            :land_value => Lot.year(year).sum(:land_value),
            :building_value => Lot.year(year).sum(:building_value),
            :appraised_value => Lot.year(year).sum(:appraised_value)
        }
      }
      chart.xAxis(categories: stats.keys)
      chart.series([{ name: 'Land Value', type: 'line', data: stats.values.map { |s| s[:land_value] } },
                    { name: 'Building Value', type: 'line', data: stats.values.map { |s| s[:building_value] } },
                    { name: 'Appraised Value', type: 'line', data: stats.values.map { |s| s[:appraised_value] } }])
      chart.credits(0)
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
      @lot_taxable = @lot_appeal
    else
      @lot_taxable = @lot.appraised_value
    end
    @lot_city_taxes_collected = (@lot_taxable * 0.01642)
    @lot_school_taxes_collected = (@lot_taxable * 0.0209)
    @lot_total_taxes_collected = (@lot_taxable * 0.03732)
    @lot_lost_to_appeal = (@lot.appraised_appraised - @lot_taxable)

    @total_lot_tax_appraised = (@lot_appraised * 0.03732)
    @total_lot_tax_appeal = (@lot_taxable * 0.03732)

    if @lot_appeal >= 10
      @city_lot_tax_lost_to_appeal = (@lot_lost_to_appeal * 0.01642)
      @school_lot_tax_lost_to_appeal = (@lot_lost_to_appeal * 0.0209)
      @total_lot_tax_lost_to_appeal = (@total_lot_tax_appraised.to_i - @total_lot_tax_appeal.to_i)
    else
      @city_lot_tax_lost_to_appeal = 0
      @school_lot_tax_lost_to_appeal = 0
      @total_lot_tax_lost_to_appeal = 0
    end

    if @lot.reputation_for(:votes) < 0
      @lot_vote = @lot.reputation_for(:votes) * -1
    else
      @lot_vote = @lot.reputation_for(:votes)
    end

    @json = @lot.to_gmaps4rails do |lot, marker|
      marker.title "#{lot.owner}"
      marker.json({ :id => lot.id })
    end
    
    if user_signed_in?
      @search = Lot.latest.search(params[:q])
    else
      @search = Lot.latest.commercial_property.search(params[:q])
    end
    @properties = @search.result.page(params[:page]).per(15).near(@lot.property_map_address, 10, order: :distance)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    @properties_for_workflow = []

    @property_value_trend = Highcharts.new do |chart|
      chart.chart(renderTo: 'graph')
      chart.title('')
      chart.yAxis(title: 'Dollars', min: 0)
      stats = {}
      @lot.versions.each { |version|
        stats[version.tax_year] = {
            :land_value => version.land_value,
            :building_value => version.building_value,
            :appraised_value => version.appraised_value
        }
      }
      chart.xAxis(categories: stats.keys)
      chart.series([{ name: 'Land Value', type: 'line', data: stats.values.map { |s| s[:land_value] } },
                    { name: 'Building Value', type: 'line', data: stats.values.map { |s| s[:building_value] } },
                    { name: 'Appraised Value', type: 'line', data: stats.values.map { |s| s[:appraised_value] } }])
      chart.credits(0)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lot }
    end
  end
end



