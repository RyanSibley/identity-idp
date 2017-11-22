module Idv
  class SubmitIdvJob
    def initialize(idv_session:, vendor_params:)
      @idv_session = idv_session
      @vendor_params = vendor_params
    end

    def submit_profile_job
      update_idv_session

      ProfileJob.perform_later(
        result_id: result_id,
        vendor: vendor.to_s,
        vendor_params: vendor_params,
        applicant_json: idv_session.applicant.to_json
      )
    end

    def submit_finance_job
      update_idv_session

      FinanceJob.perform_later(
        result_id: result_id,
        vendor: vendor.to_s,
        vendor_params: vendor_params,
        vendor_session_id: idv_session.vendor_session_id,
        applicant_json: idv_session.applicant.to_json
      )
    end

    def submit_phone_job
      update_idv_session

      PhoneJob.perform_later(
        result_id: result_id,
        vendor: vendor.to_s,
        vendor_params: vendor_params,
        vendor_session_id: idv_session.vendor_session_id,
        applicant_json: idv_session.applicant.to_json
      )
    end

    private

    attr_reader :idv_session, :vendor_params

    def result_id
      @_result_id ||= SecureRandom.uuid
    end

    def update_idv_session
      idv_session.async_result_id = result_id
      idv_session.async_result_started_at = Time.zone.now.to_i
    end

    def vendor
      idv_session.vendor || Idv::Vendor.new.pick
    end
  end
end
