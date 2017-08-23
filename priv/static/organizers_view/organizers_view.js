(() => {
  'use strict';
  const baseUrl = baseUrlRepository['alastair-cookie'];
  const apiUrl = `${baseUrl}api/`;

  const showError = (err) => {
    console.log(err);
    let message = 'Unknown cause';

    if (err && err.message) {
      message = err.message;
    } else if (err && err.data && err.data.message) {
      message = err.data.message;
    }

    $.gritter.add({
      title: 'Error',
      text: `Could not process action: ${message}`,
      sticky: false,
      time: 8000,
      class_name: 'my-sticky-class',
    });
  };

  /** @ngInject */
  function config($stateProvider) {
    // State
    $stateProvider
      .state('app.alastair_organizer', {
        url: '/alastair/organizer/welcome',
        data: { pageTitle: 'Alastair' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/welcome.html`,
            controller: 'WelcomeController as vm',
          },
        },
      });
  }


  function WelcomeController($scope, $http) {
    var vm = this;
    vm.message = "The controller works too"
  }

  angular
    .module('app.alastair_organizer', [])
    .config(config)
    .controller('WelcomeController', WelcomeController);
})();

