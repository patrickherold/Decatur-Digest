class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :new, :login_dev]
  before_filter { @main_nav = :account }

  def self.ransackable_attributes(auth_object = nil)
    %w( name email sign_in_count current_sign_in_at current_sign_in_ip ) + _ransackers.keys
  end
  

  def index
    @users = User.all
    if user_signed_in?
      @search = User.search(params[:q])
    else
      @search = User.commercial_property.search(params[:q])
    end
    
    
    @users = @search.result.page(params[:page]).per(20)
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @my_lot_votes = Lot.evaluated_by(:votes, @user)

    @my_lot_votes = @my_lot_votes.first(15)


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Account was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def login_dev
    user = User.find_by_id(params[:id])
    unless Rails.env == 'development' && user
      redirect_to '/'
      return
    end
    sign_in_and_redirect user
  end
end
