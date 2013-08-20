class PortfolioController < ApplicationController

  before_filter :user_signed_in

  def index
    @portfolio = Lot.find(params[:lot_id])
    @portfolios = @portfolio.portfolios
  end

  def new
    @portfolio = Lot.portfolios.build if user_signed_in?
    @user_id = current_user.id
    @lot_id = @lot.id
  end

  def create
    @portfolio = @portfolio.portfolios.new(params[:portfolio])
    if @comment.save
      redirect_to [@portfolios, :portfolios], notice: "Portfolio created."
    else
      render :new
    end
  end
end
