require 'rails_helper'

describe Idv::FinanceController do
  describe 'before_actions' do
    it 'includes authentication before_action' do
      expect(subject).to have_actions(
        :before,
        :confirm_two_factor_authenticated,
        :confirm_idv_session_started
      )
    end
  end

  describe '#create' do
    before do
      allow(subject).to receive(:confirm_two_factor_authenticated).and_return(true)
      allow(subject).to receive(:confirm_idv_session_started).and_return(true)
      allow(subject).to receive(:idv_session).and_return(params: {})
    end

    context 'when form is invalid' do
      context 'when finance_account is missing' do
        it 'renders #new' do
          put :create, idv_finance_form: { foo: 'bar' }

          expect(response).to render_template :new
          expect(subject.idv_session[:params]).to be_empty
        end
      end

      context 'when finance_type is invalid' do
        it 'renders #new with error' do
          put :create, idv_finance_form: { finance_type: 'foo', finance_account: '123' }

          expect(response).to render_template :new
          expect(subject.idv_session[:params]).to be_empty
        end
      end
    end

    context 'when form is valid' do
      it 'redirects to phone page' do
        put :create, idv_finance_form: { finance_type: :ccn, finance_account: '12345678' }

        expect(response).to redirect_to idv_phone_url

        expected_params = {
          ccn: '12345678'
        }
        expect(subject.idv_session[:params]).to eq expected_params
      end
    end
  end
end
