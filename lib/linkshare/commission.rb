module Linkshare
  class Commission < Base
    class << self
      def service_url
        base_url + "cli/publisher/reports/downloadReport.php"
      end
      
      def find(params = {})
        validate_params!(params, %w{bdate edate eid nid})
        params.merge!('cuserid' => credentials['user_id'], 'cpi' => credentials['pass'])
        get_service(service_url, params)
      end
      
    end # << self
  end # class
end # module