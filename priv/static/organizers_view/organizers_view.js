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
      })
      .state('app.alastair_organizer.meal', {
        url: '/event/:event_id/meal/:meal_id',
        data: { pageTitle: 'Alastair Meal' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/organizers_view/meal.html`,
            controller: 'MealController as vm',
          },
        },
      });
  }

  function WelcomeController() {
    var vm = this;
  }

  function MyEventsController($http) {
    var vm = this;
    vm.fetching = true;
    $http({
      url: apiUrl + '/events',
      method: 'GET'
    }).then(function(response) {
      vm.events = response.data.data;
      vm.fetching = false;
    }).catch(function(error) {
      showError(error);
      vm.fetching = false;
    });
  }

  function EventController($http, $stateParams, $scope) {
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
        vm.change_shop = false;
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

    vm.loadMeals = function(callback) {
      return $http({
        url: apiUrl + '/events/' + $stateParams.id + '/meals',
        method: 'GET'
      }).then(function(response) {
        vm.meals = response.data.data;
        if(callback)
          callback();
      }).catch(function(error) {
        showError(error);
      });
    }


    vm.newMeal = function() {
      $('#mealModal').modal('show');
      vm.edited_meal = {
        meals_recipes: []
      };
      vm.errors = undefined;
      $scope.$broadcast('angucomplete-alt:clearInput', 'recipeAutocomplete');
    }

    vm.editMeal = function(meal) {
      return $http({
        url: apiUrl + '/events/' + $stateParams.id + '/meals/' + meal.id,
        method: 'GET'
      }).then(function(response) {
        vm.edited_meal = response.data.data;
        $('#mealModal').modal('show');
        vm.errors = undefined;
        $scope.$broadcast('angucomplete-alt:clearInput', 'recipeAutocomplete');
        vm.edited_meal.date_options = {
          minDate: null,
          maxDate: null
        }
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.deleteMeal = function(meal) {
      return $http({
        url: apiUrl + '/events/' + $stateParams.id + '/meals/' + meal.id,
        method: 'DELETE'
      }).then(function(response) {
        vm.loadMeals(function() {
          showSuccess("Meal deleted successfully");
        });
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.addRecipe = function(recipe) {
      vm.edited_meal.meals_recipes.push({
        person_count: 1,
        recipe_id: recipe.originalObject.id,
        recipe: recipe.originalObject
      });
      $scope.$broadcast('angucomplete-alt:clearInput', 'recipeAutocomplete');
    }

    vm.fetchRecipes = function(query, timeout) {
      // Copied from the angular tutorial on how to add transformations
      function appendTransform(defaults, transform) {
        // We can't guarantee that the default transformation is an array
        defaults = angular.isArray(defaults) ? defaults : [defaults];

        // Append the new transformation to the defaults
        return defaults.concat(transform);
      }

      return $http({
        url: apiUrl + '/recipes',
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

    vm.submitForm = function() {
      // If it has an id POST, otherwise PUT
      var promise;
      if(vm.edited_meal.id) {
        promise = $http({
          url: apiUrl + '/events/' + $stateParams.id + '/meals/' + vm.edited_meal.id,
          method: 'PUT',
          data: {
            meal: vm.edited_meal
          }
        });
      } else {
        promise = $http({
          url: apiUrl + '/events/' + $stateParams.id + '/meals/',
          method: 'POST',
          data: {
            meal: vm.edited_meal
          }
        });
      }
      promise.then(function(response) {
        vm.loadMeals(function() {
          showSuccess('Meal saved successfully');
          $('#mealModal').modal('hide');
        });
      }).catch(function(error) {
        if(error.status == 422)
          vm.errors = error.data.errors;
        else
          showError(error);
      });

      return promise;
    }


    vm.loadEvent();
    vm.loadMeals();
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
      if(!vm.alt_ingredient.note)
        vm.alt_ingredient.note = {shopping_item_id: item.shopping_item_id};
      else
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

    vm.makeCsv = function(data) {
      var list = data.map(function(item) {
        var retval = {
          needed_quantity: item.calculated_quantity,
          ingredient_name: item.ingredient.name,
          measurement: item.ingredient.default_measurement.name,
          ticked: false
        }
        if(item.chosen_item) {
          retval.price = item.chosen_price;
          retval.item_quantity = item.chosen_item.item_buying_quantity;
          retval.item_unit_count = item.chosen_item.item_count;
          retval.item_name = item.chosen_item.shopping_item.name;
          retval.item_unit_price = item.chosen_item.shopping_item.price;
          retval.item_unit_quantity = item.chosen_item.shopping_item.buying_quantity;
          retval.item_comment = item.chosen_item.shopping_item.comment;
        }
        if(item.note) {
          retval.ticked = item.note.ticked;
        }

        return retval;
      });

      var csvString = convertToCsv(list); // defined in the core
      var a = document.createElement('a');
      a.href = 'data:attachment/csv,' +  encodeURIComponent(csvString);
      a.target = '_blank';
      a.download = 'shopping_list.csv';

      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
    }

    vm.loadList();
    vm.loadEvent();
  }

  function MealController($http, $stateParams) {
    var vm = this;

    vm.loadMeal = function() {
      $http({
        url: apiUrl + '/events/' + $stateParams.event_id + '/meals/' + $stateParams.meal_id,
        method: 'GET'
      }).then(function(response) {
        vm.meal = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadEvent = function() {
      $http({
        url: apiUrl + '/events/' + $stateParams.event_id,
        method: 'GET'
      }).then(function(response) {
        vm.event = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadEvent();
    vm.loadMeal();
  }

  angular
    .module('app.alastair_organizer', [])
    .config(config)
    .controller('WelcomeController', WelcomeController)
    .controller('MyEventsController', MyEventsController)
    .controller('EventController', EventController)
    .controller('ShoppingListController', ShoppingListController)
    .controller('MealController', MealController);
})();

