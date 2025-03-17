class PlantsChannel < ApplicationCable::Channel
  def subscribed
    logger.info "🌿 Client subscribing to the plants channel"
    stream_from "plants"
  end

  def unsubscribed
    logger.info "🌿 Client unsubscribed from the plants channel"
  end
end 