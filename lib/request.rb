class Request
  attr_reader :method, :path, :version, :headers, :body

  def initialize(request = "")
    parse(request)
  end

  def parse(request)
    @method, @path, @version = request.lines[0].split

    @headers = {}
    @body = {}

    mode = :headers
    request.lines[1..-1].each do |line|
      return mode = :body if line == "\r\n"

      if mode == :headers
        header, value = line.split
        add_header(header, value)
      else
        add_body(line)
      end
    end
  end

  def add_body(line)
    @body += line
  end

  def add_header(header, value)
    header = normalize(header)
    @headers[header] = value
  end

  def normalize(header)
    header.gsub(":", "").downcase.to_sym
  end
end
