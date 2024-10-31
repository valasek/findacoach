class WhatsNewController < ApplicationController
  def index
    @changelog_entries = [
      {
        version: "0.2",
        date: "October 31, 2024",
        changes: {
          "New" => [
            "Export to MS Excel, compliant with ICF requirements",
            "Security section on home page"
          ],
          "Changed" => [
            "Added statistics to the dashboard"
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
