module Idv
  class IdvJob < ApplicationJob
    def perform(_params)
      raise NotImplementedError, "subclass must implement #{__method__}"
    end

    protected

    def applicant_from_json(applicant_json)
      applicant_attributes = JSON.parse(applicant_json, symbolize_names: true)
      Proofer::Applicant.new(applicant_attributes)
    end

    def store_failed_job_result(result_id)
      job_failed_result = Idv::VendorResult.new(errors: { job_failed: true })
      VendorValidatorResultStorage.new.store(result_id: result_id, result: job_failed_result)
    end
  end
end
