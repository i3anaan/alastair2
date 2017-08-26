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

  const showSuccess = (message) => {
    $.gritter.add({
      title: 'Success',
      text: message,
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
        url: '/alastair/organizer',
        data: { pageTitle: 'Alastair Organizers View' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/welcome.html`,
            controller: 'WelcomeController as vm',
          },
        },
      })
      .state('app.alastair_organizer.my_events', {
        url: '/my_events',
        data: { pageTitle: 'Alastair My Events' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/my_events.html`,
            controller: 'MyEventsController as vm',
          },
        },
      })
      .state('app.alastair_organizer.event', {
        url: '/event/:id',
        data: { pageTitle: 'Alastair Event View' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/event.html`,
            controller: 'EventController as vm',
          },
        },
      })
      .state('app.alastair_organizer.shopping_list', {
        url: '/event/:id/shopping_list',
        data: { pageTitle: 'Alastair Shopping List' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/shopping_list.html`,
            controller: 'ShoppingListController as vm',
          },
        },
      });
  }

  function WelcomeController() {
    var vm = this;
  }

  function MyEventsController($http) {
    var vm = this;

    $http({
      url: apiUrl + '/events',
      method: 'GET'
    }).then(function(response) {
      vm.events = response.data.data;
    }).catch(function(error) {
      showError(error);
    });
  }

  function EventController($http, $stateParams) {
    var vm = this;

    vm.loadEvent = function() {
      $http({
        url: apiUrl + '/events/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.event = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.applyShop = function(shop) {
      if(shop)
        vm.event.shop_id = shop.id;
      else
        vm.event.shop_id = null;

      $http({
        url: apiUrl + '/events/' + $stateParams.id,
        method: 'PUT',
        data: {
          event: vm.event
        }
      }).then(function(response) {
        vm.event = response.data.data;
        showSuccess("Shop change successfully saved")
      }).catch(function(error) {
        showError(error);
      });
    }


    vm.fetchShops = function(query, timeout) {
      // Copied from the angular tutorial on how to add transformations
      function appendTransform(defaults, transform) {
        // We can't guarantee that the default transformation is an array
        defaults = angular.isArray(defaults) ? defaults : [defaults];

        // Append the new transformation to the defaults
        return defaults.concat(transform);
      }

      return $http({
        url: apiUrl + '/shops',
        method: 'GET',
        params: {
          limit: 8,
          query: query
        },
        transformResponse: appendTransform($http.defaults.transformResponse, function (res) {
          if(res && res.data)
            return res.data;
          else
            return [];
        }),
        timeout: timeout,
      });
    }

    vm.loadEvent();
  }

  function ShoppingListController($http, $stateParams) {
    var vm = this;
    vm.data = [];

    vm.loadEvent = function() {
      $http({
        url: apiUrl + '/events/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.event = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadList = function(callback) {
      return $http({
        url: apiUrl + '/events/' + $stateParams.id + '/shopping_list',
        method: 'GET'
      }).then(function(response) {
        vm.data = response.data.data.mapped;
        vm.unmapped = response.data.data.unmapped;
        vm.accumulates = response.data.data.accumulates;
        if(callback)
          callback();
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.showAlternatives = function(ingredient) {
      vm.alt_ingredient = ingredient;
      $('#altItemsModal').modal('show');
    }

    vm.chooseAltItem = function(item) {
      vm.alt_ingredient.note.shopping_item_id = item.shopping_item_id;
      $http({
        url: apiUrl + '/events/' + $stateParams.id + "/shopping_list/note/" + vm.alt_ingredient.ingredient_id,
        method: 'PUT',
        data: {
          note: vm.alt_ingredient.note
        }
      }).then(function(response) {
        vm.loadList(function() {
          $('#altItemsModal').modal('hide');
          showSuccess('Item switched');
        })
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.checkboxTicked = function(ingredient) {
      ingredient.note_loading = true;
      $http({
        url: apiUrl + '/events/' + $stateParams.id + "/shopping_list/note/" + ingredient.ingredient_id,
        method: 'PUT',
        data: {
          note: ingredient.note
        }
      }).then(function(response) {
        ingredient.note_loading = false;
      }).catch(function(error) {
        showError(error);
        ingredient.note_loading = false;
      });
    }

    vm.showUnmapped = function() {
      $('#unmappedModal').modal('show');
    }

    vm.loadList();
    vm.loadEvent();
  }

  angular
    .module('app.alastair_organizer', [])
    .config(config)
    .controller('WelcomeController', WelcomeController)
    .controller('MyEventsController', MyEventsController)
    .controller('EventController', EventController)
    .controller('ShoppingListController', ShoppingListController);
})();

