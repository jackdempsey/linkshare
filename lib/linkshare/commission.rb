require 'csv'
module Linkshare
  class Commission < Base
    class << self
      def service_url
        base_url + "cli/publisher/reports/downloadReport.php"
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

        CSV.parse(response.body, headers: true, col_sep: "\t", row_sep: "\t\n")
      end

      def find(params = {})
        validate_params!(params, %w{bdate edate eid nid})
        params.merge!('cuserid' => credentials['user_id'], 'cpi' => credentials['pass'])
        get_service(service_url, params)
      end

    end # << self
  end # class
end # module
