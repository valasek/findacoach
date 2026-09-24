require "ssrf_filter"

class IcsCalendarFetcher
  MAX_BYTES = 2.megabytes
  Result = Data.define(:body, :etag, :not_modified)

  class Error < StandardError; end

  def initialize(url, etag: nil)
    @url = url
    @etag = etag
  end

  def call
    body = +""
    response = nil
    headers = { "accept" => "text/calendar, text/plain;q=0.9" }
    headers["if-none-match"] = @etag if @etag.present?

    SsrfFilter.get(
      @url,
      scheme_whitelist: [ "https" ],
      max_redirects: 3,
      headers: headers,
      http_options: { open_timeout: 3, read_timeout: 5 }
    ) do |streaming_response|
      response = streaming_response
      next if response.is_a?(Net::HTTPNotModified)

      validate_response!(response)
      response.read_body do |chunk|
        raise Error, "Calendar response is too large" if body.bytesize + chunk.bytesize > MAX_BYTES

        body << chunk
      end
    end

    Result.new(body:, etag: response&.[]("etag"), not_modified: response.is_a?(Net::HTTPNotModified))
  rescue Error
    raise
  rescue SsrfFilter::Error, Timeout::Error, SocketError, IOError, SystemCallError
    raise Error, "Calendar could not be reached safely"
  end

  private

  def validate_response!(response)
    raise Error, "Calendar returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    content_length = response["content-length"].to_i
    raise Error, "Calendar response is too large" if content_length > MAX_BYTES

    content_type = response["content-type"].to_s.downcase
    return if content_type.blank? || content_type.include?("text/calendar") || content_type.include?("text/plain") || content_type.include?("application/octet-stream")

    raise Error, "Calendar response has an unsupported content type"
  end
end
