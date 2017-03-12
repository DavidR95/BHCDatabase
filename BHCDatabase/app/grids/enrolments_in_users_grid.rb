class EnrolmentsInUsersGrid
  include Datagrid

  scope do
    Enrolment
  end

  column(:id, :mandatory => true)
  column(:initiative_id, :header => 'Initiative', :mandatory => true) do |model|
    format(model.initiative_id) do |value|
      init = Initiative.find(value)
      link_to init.name, init
    end
  end
  column(:created_at, :header => 'Enrolled', :mandatory => true) do |model|
    format(model.created_at) { |value| value.strftime('%d/%m/%Y - %H:%M') }
  end
  column(:created_at, :header => 'Un-Enrolled', :mandatory => true) do |model|
    format(model.updated_at) do |value|
      value == model.created_at ? 'Still Enrolled' : value.strftime('%d/%m/%Y - %H:%M')
    end
  end
  column(:id, :header => 'Unenrol', :mandatory => true) do |model|
    format(model.id) do |value|
      @enrolment = Enrolment.find(value)
      link_to "<i class='glyphicon glyphicon-remove-sign'></i> Unenrol".html_safe, touch_enrolment_enrolment_path(@enrolment), class: "btn btn-default unenrol-btn"
    end
  end
end
