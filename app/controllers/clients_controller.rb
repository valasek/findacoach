class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /clients or /clients.json
  def index
    @clients =  if params[:show_archived] == "true"
      current_user.clients.archived.order(name: :asc).page(params[:page])
    else
      current_user.clients.unarchived.order(name: :asc).page(params[:page])
    end
    @active_clients = current_user.clients.unarchived.count
    @archived_clients = current_user.clients.archived.count
  end

  # GET /clients/1 or /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = current_user.clients.build
  end

  # GET /clients/1/edit
  def edit
  end

  # PATCH /clients/1/archive
  def archive
    @client = Client.find(params["id"])
    if @client.update(archived: true)
      redirect_to clients_path, notice: "Client has been archived successfully. Check \"Show archived clients\" to list your archived clients."
    else
      redirect_to clients_path, notice: "Failed to archive the client."
    end
  end

  # PATCH /clients/1/unarchive
  def unarchive
    @client = Client.find(params["id"])
    if @client.update(archived: false)
      redirect_to clients_path, notice: "Client is active again. Uncheck \"Show archived clients\" to list your active clients."
    else
      redirect_to clients_path, notice: "Failed to activate the client."
    end
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    @client.user_id = current_user.id

    respond_to do |format|
      if @client.save
        format.html { redirect_to clients_path, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1 or /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1 or /clients/1.json
  def destroy
    @client.destroy!

    respond_to do |format|
      format.html { redirect_to clients_path, status: :see_other, notice: "Client was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      # @client = Client.find(params[:id])
      @client = current_user.clients.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:user_id, :name, :email, :phone, :company, :position, :hours_ordered, :hours_delivered, :coaching_goal, :archived)
    end
end
