class TimecardSearch

    attr_accessor :from_date, :to_date, :bill_status, :approved , :search_text, :synced, :date_range, :client, :matter, :timekeeper,
                  :client_id, :client_name, :client_number, :matter_id, :matter_name, :matter_number, :timekeeper_name, :timekeeper_number, :query_type
    # :matter, :client, :timekeeper is excluded
    #additional_search_criteria is "ALL", "BILLABLE" AND "POSTED"
    #if from_date or to_date is null then date search criteria will not be included

    def initialize
    end

end