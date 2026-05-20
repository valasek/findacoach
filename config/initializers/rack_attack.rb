# frozen_string_literal: true

class Rack::Attack
  # Kamal Proxy forwards the real client IP via X-Forwarded-For.
  # Rack::Request#ip already reads X-Forwarded-For, so req.ip is correct here.

  # Allow localhost unrestricted (development and health checks)
  safelist("allow-localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # Limit sign-up attempts: 5 per IP per hour
  throttle("sign-up/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/users" && req.post?
  end

  # Limit login attempts: 10 per IP per 20 minutes
  throttle("login/ip", limit: 10, period: 20.minutes) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Limit password reset requests: 3 per email per hour
  throttle("password-reset/email", limit: 3, period: 1.hour) do |req|
    if req.path == "/users/password" && req.post?
      req.params.dig("user", "email").to_s.downcase.strip.presence
    end
  end

  # Return a plain 429 with a retry-after header
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    retry_after = match_data ? (match_data[:period] - (Time.now.to_i % match_data[:period])).to_s : "60"

    [
      429,
      { "content-type" => "text/plain", "retry-after" => retry_after },
      [ "Too many requests. Please try again later." ]
    ]
  end
end
