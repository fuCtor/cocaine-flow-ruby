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


    def service(name)
      @service ||= {}
      @service[name.to_s] ||= Cocaine::Service.new name
    rescue Cocaine::ServiceError => e
      @service[name.to_s] = nil
      raise e
    end

    def remove_service(name)
      @service ||= {}
      puts "Service #{name} removed"
      @service.delete name.to_s
    end


    private

    def history
      @history ||= {}
    end

  end
end

SCHEDULER.every '10s', :first_in => 0 do |job|
  storage = App.service :storage

  _tx, rx = storage.find :manifests, [:app]
  _id, value = rx.recv

  value[0].each do |a|
    begin
      app = App.service a
      _tx, rx = app.info
      _id, status = rx.recv
      App.send_event a, status[0]
    rescue Cocaine::ServiceError
      App.send_event a, { 'state' => 'stopped' }
    end
  end
end


