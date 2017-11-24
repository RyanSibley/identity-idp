module Idv
  class ProoferJob < ApplicationJob
    queue_as :idv

    attr_reader :result_id, :vendor, :vendor_params, :applicant, :vendor_session_id

    def perform(result_id:, vendor:, vendor_params:, applicant_json:, vendor_session_id: nil)
      @result_id = result_id
      @vendor = vendor.to_sym
      @vendor_params = vendor_params
      @applicant = applicant_from_json(applicant_json)
      @vendor_session_id = vendor_session_id

      perform_identity_proofing
    rescue StandardError
      store_failed_job_result
      raise
    end

    def perform_identity_proofing
      raise NotImplementedError, "subclass must implement #{__method__}"
    end

    protected

    def extract_result(confirmation)
      vendor_resp = confirmation.vendor_resp

      Idv::VendorResult.new(
        success: confirmation.success?,
        errors: confirmation.errors,
        reasons: vendor_resp.reasons
      )
    end

    def store_result(vendor_result)
      VendorValidatorResultStorage.new.store(result_id: result_id, result: vendor_result)
    end

    private

    def applicant_from_json(applicant_json)
      applicant_attributes = JSON.parse(applicant_json, symbolize_names: true)
      Proofer::Applicant.new(applicant_attributes)
    end

    def store_failed_job_result
      job_failed_result = Idv::VendorResult.new(errors: { job_failed: true })
      VendorValidatorResultStorage.new.store(result_id: result_id, result: job_failed_result)
    end
  end
end
