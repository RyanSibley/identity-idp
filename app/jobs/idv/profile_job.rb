module Idv
  class ProfileJob < IdvJob
    def perform(result_id:, vendor:, vendor_params:, applicant_json:)
      agent = Idv::Agent.new(
        applicant: applicant_from_json(applicant_json),
        vendor: vendor.to_sym
      )
      resolution = agent.start(vendor_params)
      store_result(resolution: resolution, result_id: result_id)
    rescue StandardError
      store_failed_job_result(result_id)
      raise
    end

    private

    def extract_result(resolution)
      vendor_resp = resolution.vendor_resp

      Idv::VendorResult.new(
        success: resolution.success?,
        errors: resolution.errors,
        reasons: vendor_resp.reasons,
        normalized_applicant: vendor_resp.normalized_applicant,
        session_id: resolution.session_id
      )
    end

    def store_result(resolution:, result_id:)
      result = extract_result(resolution)
      VendorValidatorResultStorage.new.store(result_id: result_id, result: result)
    end
  end
end
