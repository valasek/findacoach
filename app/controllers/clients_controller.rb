class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[ show edit update destroy ]

  # GET /clients or /clients.json
  def index
    @clients = current_user.clients.order(created_at: :desc)
    @clients_count = @clients.count
    respond_to do |format|
      format.html do
        if params[:query].present?
          query = "%#{params[:query].downcase}%"
          @clients = @clients.where("LOWER(name) LIKE ? OR LOWER(email) LIKE ?", query, query).page(params[:page])
        else
          @clients = @clients.page(params[:page])
        end
      end
      format.xlsx do
        template_path = "#{Rails.root}/app/assets/templates/ICFClientCoachingLogTemplate-20-1.xlsx"
        workbook = RubyXL::Parser.parse(template_path)
        worksheet = workbook[0]
        current_row = 2
        @clients.each do |client|
          sessions = client.sessions
          first_session = sessions.order(date: :asc).last
          start_month = first_session&.date&.strftime("%B %Y") || "No sessions"
          last_session = sessions.order(date: :asc).first
          end_month = last_session&.date&.strftime("%B %Y") || "No sessions"
          max_group_size = sessions.maximum(:group_size) || 0
          paid_duration = sessions.where(paid: true).sum(:duration)
          unpaid_duration = sessions.where(paid: false).sum(:duration)
          data = [
            client.name,
            [ client.phone.presence, client.email.presence ].compact.join(", "),
            max_group_size > 1 ? "Group" : "Individual",
            max_group_size > 1 ? max_group_size : "",
            start_month,
            end_month,
            paid_duration,
            unpaid_duration
          ]
          data.each_with_index do |value, col_index|
            style_cell = worksheet[2][col_index]
            # Create new cell with the same style as the template
            new_cell = worksheet.add_cell(current_row, col_index, value)
            if style_cell && style_cell.style_index
              new_cell.style_index = style_cell.style_index
            end
          end
          current_row += 1
        end
        send_data workbook.stream.string,
          filename: "ICFClientCoachingLog.xlsx",
          type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      end
    end
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
    @sessions = @client.sessions
  end

  # POST /clients or /clients.json
  def create
    @client = Client.new(client_params)
    @client.user = current_user

    respond_to do |format|
      if @client.save
        format.html { redirect_to client_path(@client), notice: "Client was successfully created." }
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
      format.html { redirect_to clients_path, status: :see_other, notice: "Client was successfully removed." }
      format.json { head :no_content }
    end
  end

  private
    def set_client
      @client = Client.find(params.expect(:id))
    end

    def client_params
      params.require(:client).permit(:user_id, :name, :email, :phone, :notes)
    end
end
