class SessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, except: [ :create, :index ]  # Don't set client for create and index
  before_action :set_session, only: %i[ show edit update destroy ]

  # GET /sessions or /sessions.json
  def index
    @sessions = current_user.sessions.all
  end

  # GET /sessions/1 or /sessions/1.json
  def show
  end

  # GET /sessions/new
  def new
    @session = @client.sessions.build
  end

  # GET /sessions/1/edit
  def edit
  end

  # POST /sessions or /sessions.json
  def create
    client_id = params[:client_id]
    @client = current_user.clients.find(client_id) if client_id.present?
    if @client.nil?
      @session = Session.new(session_params)
      flash.now[:alert] = "Please select a client"
      render :new, status: :unprocessable_entity
      return
    end
    @session = @client.sessions.build(session_params)

    respond_to do |format|
      if @session.save
        format.html { redirect_to client_path(@client), notice: "Session was successfully created." }
        format.json { render :show, status: :created, location: clients_path }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sessions/1 or /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to client_path(@client), notice: "Session was successfully updated." }
        format.json { render :show, status: :ok, location: clients_path }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json
  def destroy
    @session.destroy!

    respond_to do |format|
      format.html { redirect_to client_path(@client), status: :see_other, notice: "Session was successfully removed." }
      format.json { head :no_content }
    end
  end

  private

    def set_client
      @client = current_user.clients.find(params[:client_id])
    end

    def set_session
      @session = @client.sessions.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.expect(session: [ :client_id, :date, :duration, :paid, :group, :group_size, :notes ])
    end
end
