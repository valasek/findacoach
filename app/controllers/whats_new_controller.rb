class WhatsNewController < ApplicationController
  def index
    @changelog_entries = [
      {
        version: "0.1",
        date: "September 23, 2024",
        changes: {
          "New" => [
            "First version of Find a Coach to gather initial feedback",
            "Generally available for all users without restrictions"
          ]
          # "Changed" => [
          #   "...",
          #   ""
          # ],
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      }
      # Add more changelog entries here
    ]
  end
end
