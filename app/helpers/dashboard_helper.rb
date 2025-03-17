module DashboardHelper
  def plant_status_color(status)
    case status
    when 'dry'
      'bg-yellow-100 text-yellow-800'
    when 'optimal'
      'bg-green-100 text-green-800'
    when 'wet'
      'bg-blue-100 text-blue-800'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end
