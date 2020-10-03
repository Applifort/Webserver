# ab -n 10000 -c 100 -p ./section_one/ostechnix.txt localhost:1234/
# head -c 100000 /dev/urandom > section_one/ostechnix_big.txt

require 'socket'
require './lib/response'
require './lib/request'
MAX_EOL = 5

socket = TCPServer.new(ENV['HOST'], ENV['PORT'])

CONTENT_TYPES = { 'txt' => 'text/plain', 'json' => 'application/json', 'html' => 'text/html' }

def handle_request(request_text, client)
  puts
  request  = Request.new(request_text)
  path = request.path

  puts "#{client.peeraddr[3]} #{path}"

  file_path = "files#{path}"

  if File.exists?(file_path)
    if file_readable?(file_path)
      content = File.read(file_path)
      extension = File.extname(file_path).slice(1..-1)
      content_type = CONTENT_TYPES[extension] || 'text/plain'

      response = Response.new(code: 200, data: content, headers: ["Content-Type: #{content_type}"])
    else
      response = Response.new(code: 403)
    end
  else
    response = Response.new(code: 404)
  end

  response.send(client)

  client.shutdown
end

def file_readable?(file_path)
  File.stat(file_path).mode.to_s(8)[5..5].to_i > 3
end

def handle_connection(client)
  puts "Getting new client #{client}"
  request_text = ''
  last_4_bytes = '****'

  loop do
    buf = client.recv(1)
    request_text += buf

    last_4_bytes = update_last_4_bytes(buf, last_4_bytes)

    if last_4_bytes == "\r\n\r\n"

      request_text.each_line do |line|
        next unless line.downcase.match?('content-length')
        length = line.scan(/\d/).join('').to_i
        request_text += client.recv(length)
      end

      handle_request(request_text, client)
      break
    end
  end
rescue => e
  puts "Error: #{e}"

  response = Response.new(code: 500, data: "Internal Server Error")
  response.send(client)

  client.close
end

def update_last_4_bytes(byte, bytes)
  bytes_without_first = bytes.slice(1..-1)
  "#{bytes_without_first}#{byte}"
end

puts "Listening on #{ENV['HOST']}:#{ENV['PORT']}. Press CTRL+C to cancel."

loop do
  Thread.start(socket.accept) do |client|
    handle_connection(client)
  end
end

