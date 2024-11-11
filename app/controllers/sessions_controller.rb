class SessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client
  before_action :set_session, only: [ :show, :edit, :update, :destroy ]

  def index
    @sessions = @client.sessions
  end

  def show
  end

  def new
    @session = @client.sessions.build
  end

  def edit
  end

  def create
    @session = @client.sessions.build(session_params)

    respond_to do |format|
      if @session.save
        if params[:source] == "edit"
          format.html { redirect_to edit_client_path(@client), notice: "Session was successfully created." }
        else
          format.html { redirect_to clients_path, notice: "Session was successfully created." }
        end
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to edit_client_path(@client), notice: "Session was successfully updated." }
        format.turbo_stream { redirect_to edit_client_path(@client), notice: "Session was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@session, partial: "form", locals: { session: @session }) }
      end
    end
  end

  def destroy
    @session.destroy
    respond_to do |format|
      format.html { redirect_to edit_client_path(@client), notice: "Session was successfully deleted." }
      format.turbo_stream { redirect_to edit_client_path(@client), notice: "Session was successfully deleted." }
    end
  end

  private

  def set_client
    @client = current_user.clients.find(params[:client_id])
  end

  def set_session
    @session = @client.sessions.find(params[:id])
  end

  def session_params
    params.require(:session).permit(:date, :duration, :notes, :paid)
  end
end
