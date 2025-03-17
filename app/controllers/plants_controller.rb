class PlantsController < ApplicationController
  before_action :set_plant, only: [:show, :edit, :update, :destroy]

  def index
    @plants = Plant.all
    redirect_to root_path(view: params[:view])
  end

  def show
  end

  def new
    @plant = Plant.new
  end

  def edit
  end

  def create
    @plant = Plant.new(plant_params)

    if @plant.save
      redirect_to @plant, notice: 'Plant was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @plant.update(plant_params)
      redirect_to @plant, notice: 'Plant was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plant.destroy
    redirect_to root_path, notice: 'Plant was successfully deleted.'
  end

  # HTMX endpoint to get updated plant rows
  def table_rows
    @plants = Plant.order(:slug)
    Rails.logger.info "📊 HTMX table_rows endpoint hit at #{Time.current}"
    
    respond_to do |format|
      format.html { render layout: false }
      format.any { head :not_acceptable }
    end
  end

  private

  def set_plant
    @plant = Plant.find_by!(slug: params[:id])
  end

  def plant_params
    params.require(:plant).permit(
      :species, 
      :location, 
      :slug, 
      :preferred_moisture_min, 
      :preferred_moisture_max
    )
  end
end 