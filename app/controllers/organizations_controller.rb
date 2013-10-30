class OrganizationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_super_admin!, :except => [:show, :edit]
  before_filter { @main_nav = :organizations }

  def index
    @title = "LiteGov Organizations"
    @organizations = Organization.all.sort_by(&:created_at)
  end

  def show
    @organization = Organization.find_by_id(params[:id])
    @main_nav = :organization
    if @organization && (@organization.admins.include?(current_user) || current_user.super_admin?)
      @title = @organization.name
    else
      flash[:alert] = 'Insufficient permissions'
      redirect_to '/'
    end
  end

  def new
    @title = "New Organization"
    @organization = Organization.new
    if request.post?
      @organization = Organization.new(params[:organization])
      redirect_to organizations_path if @organization.save
    end
  end

  def edit
    @title = "Edit Organization"
    @organization = Organization.find_by_id(params[:id])

    unless @organization.admins.include?(current_user)
      flash[:alert] = 'Insufficient permissions'
      redirect_to '/'
    end unless current_user.super_admin?

    if request.post?
      if @organization.update_attributes(params[:organization])
        if current_user.super_admin? && !current_user.organization == @organization
          redirect_to organizations_path
        else
          redirect_to organization_path(@organization)
        end
      end
    end
  end

  def delete
    organization = Organization.find_by_id(params[:id])
    if organization
      organization.users.map(&:unassign!)
      organization.delete
      flash[:notice] = 'Organization deleted. All organization users unassigned'
    else
      flash[:alert] = 'Could not find the specified organization'
    end
    redirect_to organizations_path
  end
end
