class InitiativesController < ApplicationController
  skip_before_action :admin_only, only: [:show]

  before_action :correct_initiative_only
  before_action :archive_redirect, only: [:show]

  def index

    # Permit params to allow conversion to a hash
    params[:initiatives_grid].permit! unless params[:initiatives_grid].nil?

    # Instantiate the grid, without any archived rows
    @initiatives_grid = InitiativesGrid.new(params[:initiatives_grid]) { |scope| scope.where(:archived => false) }

    respond_to do |f|
      f.html do
        # Display the grid as normal
        @initiatives_grid.scope { |scope| scope.page(params[:page]) }
      end
      f.csv do
        # Upon csv url format, send the grid to a downloadable csv file
        send_data @initiatives_grid.to_csv,
                  type: 'text/csv',
                  disposition: 'inline',
                  filename: "initiatives-#{Time.now.to_s}.csv"
      end
    end
  end

  def show
    @initiative = Initiative.find(params[:id])
    @area = Area.find(@initiative.area_id)
    @meetings = Meeting.where(initiative_id: @initiative)
    @average_attendance = 0
    begin
      @initiative.meetings.each { |meeting| @average_attendance += meeting.attendance }
      @average_attendance /= @initiative.meetings.count
    rescue
      @average_attendance = 0
    end

    # Builds a DataGrid that shows only the users that belong to this specific initiative
    @users_grid = UsersGrid.new(params[:users_grid]) { |scope| scope.where(:id => @initiative.users.ids, :archived => false) }
    # Builds a DataGrid that shows only the meetings that belong to this specific initiative
    @meetings_in_initiatives_grid = MeetingsInInitiativesGrid.new(params[:meetings_in_initiatives_grid]) do |scope|
      scope.where(:initiative_id => @initiative).page(params[:page])
    end
    @funders_for_initiative_grid = FundersForInitiativeGrid.new(params[:funders_for_initiative_grid]) do |scope|
      scope.where(:id => @initiative.initiative_funders.ids)

    end
    @removed_funders_for_initiative_grid = RemovedFundingsForInitiativesGrid.new(params[:removed_fundings_for_initiatives_grid]) do |scope|
      scope.where(:id => @initiative.removed_initiative_fundings.ids)
    end

    @last_meeting = @meetings.where.has{datetime <= Time.zone.now}.ordering{datetime.desc}.first
    @next_meeting = @meetings.where.has{datetime >= Time.zone.now}.ordering{datetime.asc}.first
  end

  def new
    @initiative = Initiative.new
    @areas = Area.where(:archived => false)
  end

  def create
    @initiative = Initiative.new(initiative_params)
    @areas = Area.where(:archived => false)
    if @initiative.save
      flash[:success] = 'Created the new initiative!'
      redirect_to @initiative
    else
      render 'new'
    end
  end

  def edit
    @initiative = Initiative.find(params[:id])
    @areas = Area.where(:archived => false)
  end

  def update
    @initiative = Initiative.find(params[:id])
    @areas = Area.where(:archived => false)
    if @initiative.update(initiative_params)
      flash[:success] = 'Initiative was successfully updated'
      redirect_to @initiative
    else
      render 'edit'
    end
  end

  def destroy
    if Initiative.find(params[:id]).destroy
      flash[:success] = 'Initiative successfully deleted.'
    else
      flash[:danger] = 'An unknown error occurred and the initiative was not deleted. Please try again later or contact support.'
    end
    redirect_to initiatives_url
  end

  def archive
    @initiative = Initiative.find(params[:id])
  end

  def update_archive
    @initiative = Initiative.find(params[:id])
    if @initiative.update(archive_params)
      redirect_to @initiative
    else
      render 'archive'
    end
  end

  def unarchive
    @initiative = Initiative.find(params[:id])
    if @initiative.update(:archived => false, :reason_archived => nil)
      flash[:success] = 'Initiative is no longer archived'
    else
      flash[:danger] = "An unknown error occurred and the initiative was not un-archived. Please try again later or contact support."
    end
    redirect_to @initiative
  end

  def am_i_archived?
    Initiative.find(params[:id]).archived?
  end

  private

  def initiative_params
    params.require(:initiative).permit(:name, :description, :area_id, :location, :archived, :reason_archived)
  end

  def archive_params
    params.require(:initiative).permit(:archived, :reason_archived)
  end

# Ensure that only a user, at least a volunteer, who is enrolled for a particular initiative can access it
  def correct_initiative_only
    unless current_user.admin?
      if current_user.service_user? || current_user.initiatives.exclude?(Initiative.find(params[:id]))
        flash[:danger] = 'You are not allowed to access that page.'
        redirect_to current_user
      end
    end
  end
end
