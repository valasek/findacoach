class WhatsNewController < ApplicationController
  def index
    @changelog_entries = [
      {
        version: "0.3",
        date: "November 4, 2024",
        changes: {
          "New" => [
            "Full demo version available"
          ],
          "Changed" => [
            "Upgrade the underlying technology to Rails 8.0.0"
          ]
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      },
      {
        version: "0.2",
        date: "October 31, 2024",
        changes: {
          "New" => [
            "Export to MS Excel, compliant with ICF requirements",
            "Security hardening and new security section on home page"
          ],
          "Changed" => [
            "New statistics to the dashboard"
          ]
          # "Fixed" => [
          #   "",
          #   ""
          # ]
        }
      },
      {
        version: "0.1",
        date: "October 23, 2024",
        changes: {
          "New" => [
            "Find a Coach - alpha version. First release to gather initial feedback",
            "Available for all users without any restrictions",
            "Coach can manage clients and coaching hours per client"
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
    ]
  end
end
