# http://helpcenter.linkshare.com/publisher/questions.php?questionid=652
module Linkshare
  class Product < Base

    PARAMS = %w[token cat max maxResults pagenumber mid keyword exact one none sort sorttype] # cat = Category, mid = Advertister

    BASE_URL = 'http://productsearch.linksynergy.com/productsearch'

    class << self
      def service_url
        BASE_URL
      end

      def find(params = {})
        validate_params!(params)
        result = get_service(service_url, params)
        Array.wrap(result['result']['item']).collect{ |product| self.new(product) }
      end

      def validate_params!(params)
        params.merge!('token' => credentials['token'])
        super(params, PARAMS)
      end
    end

    def initialize(product)
      super(product)
    end

  end
end