require 'ostruct'

module App
  class << self
    def configuration
      yield(config) if block_given?
    end

    def config
      @config ||= OpenStruct.new( )
    end

    def connections
      @connections ||= []
    end

    def latest_events
      history.inject('') do |str, (id, body)|
        str << body
      end
    end

    def format_event(body, name=nil)
      str = ''
      str << "event: #{name}\n" if name
      str << "data: #{body}\n\n"
    end

    def send_event(id, body, target=nil)
      body[:id] = id
      body[:updatedAt] ||= Time.now.to_i
      event = format_event(body.to_json, target)
      history[id] = event
      connections.each { |out| out << event }
    end

    private

    def history
      @history ||= []
    end

  end
end