module Idv
  class PhoneJob < IdvJob
    def perform(result_id:, vendor:, vendor_params:, applicant_json:, vendor_session_id:)
      agent = Idv::Agent.new(
        applicant: applicant_from_json(applicant_json),
        vendor: vendor.to_sym
      )
      confirmation = agent.submit_phone(vendor_params, vendor_session_id)
      store_result(confirmation: confirmation, result_id: result_id)
    rescue StandardError
      store_failed_job_result(result_id)
      raise
    end

    private

    def extract_result(confirmation)
      vendor_resp = confirmation.vendor_resp

      Idv::VendorResult.new(
        success: confirmation.success?,
        errors: confirmation.errors,
        reasons: vendor_resp.reasons
      )
    end

    def store_result(confirmation:, result_id:)
      result = extract_result(confirmation)
      VendorValidatorResultStorage.new.store(result_id: result_id, result: result)
    end
  end
end
