module Linkshare
  class Coupon < Base
    class << self
      def service_url
        "http://couponfeed.linksynergy.com/coupon"# category=4169&promotiontype=21&network=1&resultsperpage=100&pagenumber=2
      end

      def find(params = {})
        validate_params!(params, %w{category promotiontype network pagenumber})
        params.merge!('token' => credentials['token'])
        result = get_service(service_url, params)
        Array.wrap(result['couponfeed']['link']).map { |coupon| self.new(coupon) }
      end

    end # << self
    def initialize(coupon)
      super(coupon)
    end

    # a note on link ids from their docs
    # <advertiserid>000</advertiserid>
    # <clickurl>http://click.linksynergy.com/fsbin/click?id=XXXXXXXXXXX&offerid=164317.10002595&type=4&subid=0</clickurl>
    #
    # The advertiserid value is 000, the link type value is 4, and the link id is 10002595, making the unique ID for this link: 000_4_10002595.
    def link_id
      parsed_url = URI.parse(clickurl)
      offer_id_match = parsed_url.query.match(/offerid=([^&]+)\&/)
      type_match = parsed_url.query.match(/type=([^&]+)\&/)
      if offer_id_match and type_match
        bare_link_id = offer_id_match[1] && offer_id_match[1].split('.').last
        [advertiserid, type_match[1], bare_link_id].join('_')
      end
    end
  end # class
end # module
