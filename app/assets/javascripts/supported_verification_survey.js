(function(global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    GOVUK.supportedVerificationSurvey = {
        init: function() {
            var supportedVerificationSurvey = $('#supported-verification-survey');

            function sendPiwikAction(response) {
                console.log('Report to piwik: ' + response);
                global._paq.push(['trackEvent', 'supported-verification-survey', global.location.href, 'Supported Verification Survey response: ' + response]);
                supportedVerificationSurvey.find('.question').hide();
                supportedVerificationSurvey.find('.thank-you-message').show();
            }

            if (supportedVerificationSurvey.length) {
                $('#answer-yes').click(function() {
                    sendPiwikAction('yes');
                });
                $('#answer-no').click(function() {
                    sendPiwikAction('no');
                });
            }
        }
    };
})(window);