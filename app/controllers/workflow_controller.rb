class WorkflowController < ApplicationController
  before_filter :authenticate_user!
  before_filter { @main_nav = :workflows }

  def my
    @title = 'My Workflows'
    @workflows = current_user.workflows
  end

  def managed
    @title = 'Managed Workflows'
    @managed = true
    @workflows = current_user.managed_workflows
    render :my
  end

  def new
    @title = "New Workflow"
    if request.post?
      @workflow = Workflow.new({ :user => current_user }.merge(params[:workflow]))
      redirect_to my_workflows_path if @workflow.save
    else
      @workflow = Workflow.new({ :user => current_user })
    end
  end

  def edit
    @title = "Edit Workflow"
    @workflow = Workflow.find(params[:id])
    unless @workflow.user == current_user
      redirect_to my_workflows_path
      return
    end
    if request.post?
      redirect_to my_workflows_path if @workflow.update_attributes(params[:workflow])
    end
  end

  def view
    @title = "Workflow Details"
    @workflow = Workflow.find(params[:id])
    unless @workflow.accessible_by(current_user)
      redirect_to my_workflows_path
      return
    end
  end

  def delete
    @workflow = Workflow.find(params[:id])
    @workflow.delete if @workflow.user == current_user
    redirect_to my_workflows_path
  end

  # add property to workflow
  def add
    @workflow = Workflow.find(params[:workflow])
    @lot = Lot.find(params[:lot])
    if @workflow.accessible_by(current_user)
      @workflow.lots << @lot unless @workflow.lots.include?(@lot)
      @workflow.save!
    end
    render :json => 'ok'
  end

  # remove property from workflow
  def remove
    @workflow = Workflow.find(params[:workflow])
    @lot = Lot.find(params[:lot])
    if @workflow.accessible_by(current_user)
      @workflow.lots.delete(@lot) if @workflow.lots.include?(@lot)
      @workflow.save!
    end
    if params.keys.include?(:ajax)
      render :text => 'ok'
    else
      redirect_to :back
    end
  end

  def lot
    @title = "Property Workflows"
    @lot = Lot.find(params[:id])
    if request.post?
      workflows = current_user.workflows + current_user.managed_workflows
      active_workflows = params[:workflows].map {|w| Workflow.find_by_id(w) }.compact
      workflows.each {|workflow|
        workflow.lots.delete(@lot)
        workflow.lots << @lot if active_workflows.include?(workflow)
        workflow.save!(:validate => false)
      }
    end
  end
end
