class AreasController < ApplicationController

  def index
    @areas = Area.all
    @areas_grid = AreasGrid.new(params[:areas_grid]) do |scope|
      scope.page(params[:page])
    end
  end

  def show
    @area = Area.find(params[:id])
    @initiatives = Initiative.where(area_id: @area)
    @initiatives_in_area_grid = InitiativesInAreaGrid.
        new(params[:initiatives_in_area_grid]) do |scope|
      scope.where(:area_id => @area).page(params[:page])
    end
  end

  def new
    @area = Area.new
  end

  def create
    @area = Area.new(area_params)
    if @area.save
      flash[:success] = 'Created the new area!'
      redirect_to @area
    else
      render 'new'
    end
  end

  def edit
    @area = Area.find(params[:id])
  end

  def update
    @area = Area.find(params[:id])
    if @area.update_attributes(area_params)
      flash[:success] = 'Area updated'
      redirect_to @area
    else
      render 'edit'
    end
  end

  def destroy
    Area.find(params[:id]).destroy
    flash[:success] = 'Area deleted'
    redirect_to areas_url
  end

  def archive
    @area = Area.find(params[:id])
  end

  def update_archive
    @area = Area.find(params[:id])
    unless @area.update_attribute(:archived, archive_params[:archived])
      flash[:danger] = 'Something went wrong'
      redirect_to @area
      return
    end
    unless @area.update_attribute(:reason_archived, archive_params[:reason_archived])
      flash[:danger] = 'Something went wrong'
      redirect_to @area
      return
    end
    redirect_to @area
  end

  def unarchive
    @area = Area.find(params[:id])
    unless @area.update_attribute(:archived, false)
      flash[:danger] = 'Something went wrong'
      redirect_to @area
      return
    end
    unless @area.update_attribute(:reason_archived, nil)
      flash[:danger] = 'Something went wrong'
      redirect_to @area
      return
    end
    flash[:success] = 'User is no longer archived'
    redirect_to @area
  end

  def is_archived?
    Area.find(params[:id]).archived
  end

  private

  def area_params
    params.require(:area).permit(:name, :description, :archived, :reason_archived)
  end
  def archive_params
    params.require(:area).permit(:archived, :reason_archived)
  end
end
