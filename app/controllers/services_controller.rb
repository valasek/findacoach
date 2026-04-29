class ServicesController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_user, except: [ :create, :index ]  # Don't set user for create and index
  before_action :set_service, only: %i[ show edit update destroy ]

  # GET /services or /services.json
  def index
    @services = current_user.services.all
  end

  # GET /services/1 or /services/1.json
  def show
  end

  # GET /services/new
  def new
    @service = current_user.services.build
  end

  # GET /services/1/edit
  def edit
  end

  def create
    @service = current_user.services.build(service_params)

    if @service.save
      redirect_to edit_user_registration_path, notice: "Service added."
    else
      redirect_to edit_user_registration_path, alert: @service.errors.full_messages.to_sentence
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to edit_user_registration_path, notice: "Service updated." }
        format.json { render json: { name: @service.name }, status: :ok }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    @service = current_user.services.find(params[:id])
    redirect_to edit_user_registration_path, alert: "Service in use. Change the service on relevant sessions before deleting it." and return if @service.sessions.any?
    @service.destroy
    redirect_to edit_user_registration_path, notice: "Service removed."
  end

  private

    def set_user
      @user = current_user.services.find(params[:user_id])
    end

    def set_service
      @service = current_user.services.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.require(:service).permit(:client_id, :name, :default)
    end
end
