module Linkshare
  class Base
    include HTTParty
    format :xml 

    attr_reader :total_pages, :total_matches, :page_number
    
    @@credentials = {}
    @@default_params = {}
    
    def initialize(params)
      raise ArgumentError, "Init with a Hash; got #{params.class} instead" unless params.is_a?(Hash)

      params.each do |key, val|
        instance_variable_set("@#{key}".intern, val)
        instance_eval " class << self ; attr_reader #{key.intern.inspect} ; end "
      end
    end
    
    def user_id=(id)
      @@credentials['user_id'] = id.to_s
    end
    
    def pass=(pass)
      @@credentials['pass'] = pass.to_s
    end
    
    class << self
      def base_url
        "http://cli.linksynergy.com/"
      end
      
      def validate_params!(provided_params, available_params, default_params = {})
        params = default_params.merge(provided_params)
        invalid_params = params.select{|k,v| !available_params.include?(k.to_s)}.map{|k,v| k}
        raise ArgumentError.new("Invalid parameters: #{invalid_params.join(', ')}") if invalid_params.length > 0
        params
      end
      
      def get_service(path, query)
        query.keys.each{|k| query[k.to_s] = query.delete(k)}

        results = []
        begin
          # pairs = [] ; query.each_pair{|k,v| pairs << "#{k}=#{v}" } ; p "#{path}&#{pairs.join('&')}"
          response = get(path, :query => query, :timeout => 30)
        rescue Timeout::Error
          nil
        end

        raise_if_invalid_response(response)

        Crack::XML.parse(response.body)
      end
      
      def credentials
        unless @@credentials && @@credentials.length > 0
          config_file = ["config/linkshare.yml", File.join(ENV['HOME'], '.linkshare.yaml')].select{|f| File.exist?(f)}.first

          unless File.exist?(config_file)
            warn "Warning: config/linkshare.yaml does not exist. Put your CJ developer key and website ID in ~/.linkshare.yml to enable live testing."
          else
            @@credentials = YAML.load(File.read(config_file))
          end
        end
        @@credentials
      end
      
      def raise_if_invalid_response(response)
        raise ArgumentError, "There was an error connecting to LinkShare's reporting server." if response.body.include?("REPORTING ERROR")
      end
      
      def first(params)
        find(params).first
      end
    
    end
  end
end
