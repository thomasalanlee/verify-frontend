(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  var selectProofOfAddress = {
    init: function (){
      selectProofOfAddress.$form = $('#validate-proof-of-address');
      var errorMessage = selectProofOfAddress.$form.data('msg');
      if (selectProofOfAddress.$form.length === 1) {
        selectProofOfAddress.validator = selectProofOfAddress.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
          rules: {
            'select_proof_of_address_form[debit_card]': 'required',
            'select_proof_of_address_form[credit_card]': 'required',
          },
            groups: {
                primary: 'select_proof_of_address_form[credit_card] select_proof_of_address_form[debit_card]'
            },
          messages: {
            'select_proof_of_address_form[debit_card]': errorMessage,
            'select_proof_of_address_form[credit_card]': errorMessage
          }
        }));
      }
    }
  };

  GOVUK.selectProofOfAddressNoBankAccount = selectProofOfAddress;

  global.GOVUK = GOVUK;
})(window);
