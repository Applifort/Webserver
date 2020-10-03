class Response
  attr_reader :code

  def initialize(code:, headers: [], data: "")
    @code = code
    @data = data
    @headers = headers
  end

  def headers
    "HTTP/1.1 #{@code}\r\n" +
    "Content-Length: #{@data.bytesize}\r\n" +
    @headers.join("\r\n") +
    "\r\n"
  end

  def body
    "#{@data}\r\n"
  end

  def send(client)
    puts "Respond with #{@code}"
    response = headers + body
    client.write(response)
  end
end
