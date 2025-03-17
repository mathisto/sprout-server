module ApplicationHelper
  def plant_status_color(status)
    case status.to_s.downcase
    when 'dry'
      'bg-tokyonight-red bg-opacity-70 text-tokyonight-white'
    when 'optimal'
      'bg-tokyonight-green bg-opacity-70 text-tokyonight-white'
    when 'wet'
      'bg-tokyonight-blue bg-opacity-70 text-tokyonight-white'
    else
      'bg-tokyonight-black text-tokyonight-white'
    end
  end
end
