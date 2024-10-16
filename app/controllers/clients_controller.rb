class ClientsController < ApplicationController
  before_action :set_client, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /clients or /clients.json
  def index
    @clients = current_user.clients.order(created_at: :desc)

    if params[:query].present?
      query = "%#{params[:query].downcase}%"
      @clients = @clients.where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", query, query)
    end

    @clients = @clients.page(params[:page])
    @clients_count = current_user.clients.count
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
        format.html { redirect_to clients_path, notice: "Client was successfully updated." }
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
      format.html { redirect_to clients_path, status: :see_other, notice: "Client was successfully deleted." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = current_user.clients.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def client_params
      params.require(:client).permit(:user_id, :name, :email, :phone, :notes)
    end
end
