require 'rails_helper'

describe Idv::FinanceForm do
  subject { Idv::FinanceForm.new({}) }

  it do
    is_expected.
      to validate_presence_of(:finance_type).with_message("can't be blank")
  end

  it do
    is_expected.
      to validate_presence_of(:finance_account).with_message("can't be blank")
  end

  describe '#submit' do
    it 'adds ccn key to idv_params when valid' do
      expect(subject.submit(finance_account: '12345678', finance_type: :ccn)).to eq true

      expected_params = {
        ccn: '12345678'
      }

      expect(subject.idv_params).to eq expected_params
    end

    it 'fails when missing all finance fields' do
      expect(subject.submit(foo: 'bar')).to eq false
    end
  end
end
