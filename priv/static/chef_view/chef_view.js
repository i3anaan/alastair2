(() => {
  'use strict';
  const baseUrl = baseUrlRepository['alastair-cookie'];
  const apiUrl = `${baseUrl}api/`;

  const showError = (err) => {
    console.log(err);
    let message = 'Unknown cause';

    if (err && err.message) {
      message = err.message;
    } else if (err && err.error) {
      message = err.error;
    }else if (err && err.data && err.data.message) {
      message = err.data.message;
    } else if (err && err.data && err.data.error) {
      message = err.data.error;
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

  const infiniteScroll = ($http, vm, url) => {

    vm.pageSize = 20;
    vm.raceCounter = 0;
    vm.search = "";

    vm.resetData = function() {
      vm.block_infinite_scroll = false;
      vm.busy = false;
      vm.data = [];
      vm.page = 0;
      return vm.loadNextPage();
    }

    vm.loadNextPage = function() {
      vm.block_infinite_scroll = true;
      vm.busy = true;
      vm.raceCounter++;
      var localRaceCounter = vm.raceCounter;
      // TODO implement pagination in the backend
      return $http({
        url: url,
        method: 'GET',
        params: {
          query: vm.search,
          limit: vm.pageSize,
          offset: vm.pageSize*vm.page
        }
      }).then(function(response) {
        if(localRaceCounter == vm.raceCounter) {
          vm.busy = false;
          if(response.data.data.length > 0) {
            vm.page++;
            vm.data.push.apply(vm.data, response.data.data);
            vm.block_infinite_scroll = false;
          }
        }
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.resetData();
  };

  const loadMeasurements = ($http, vm) => {
    $http({
      url: apiUrl + 'measurements',
      method: 'GET'
    }).then(function(response) {
      vm.measurements = response.data.data;
    }).catch(function(err) {
      showError(err);
    })
  };

  /** @ngInject */
  function config($stateProvider) {
    // State
    $stateProvider
      .state('app.alastair_chef', {
        url: '/alastair/chef',
        data: { pageTitle: 'Alastair Chef-View' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/welcome.html`,
            controller: 'WelcomeController as vm',
          },
        },
      })
      .state('app.alastair_chef.ingredients', {
        url: '/ingredients',
        data: { pageTitle: 'Alastair Ingredients' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/ingredients.html`,
            controller: 'IngredientController as vm',
          }
        }
      })
      .state('app.alastair_chef.recipes', {
        url: '/recipes',
        data: { pageTitle: 'Alastair Recipes' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/recipes.html`,
            controller: 'RecipeController as vm'
          }
        }
      })
      .state('app.alastair_chef.single_recipe', {
        url: '/recipes/:id',
        data: { pageTitle: 'Alastair Single Recipe' },
        params: {
          create: false
        },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/single_recipe.html`,
            controller: 'SingleRecipeController as vm'
          }
        }
      });
  }


  function WelcomeController() {
    var vm = this;
  }

  function IngredientController($http) {
    var vm = this;

    // TODO fetch permissions from backend
    vm.permissions = {
      superuser: true
    };

    vm.pageSize = 20;
    vm.raceCounter = 0;
    vm.measurements = [];



    vm.submitForm = function() {
      // If if has an id, we should put there
      // Otherwise post
      if(vm.edited_ingredient.id) {
        $http({
          url: apiUrl + 'ingredients/' + vm.edited_ingredient.id,
          method: 'PUT',
          data: {
            ingredient: vm.edited_ingredient
          }
        }).then(function(response) {
          vm.resetData();
          $('#ingredientModal').modal('hide');
          showSuccess('Ingredient updated successfully')
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      } else {
        $http({
          url: apiUrl + 'ingredients/',
          method: 'POST',
          data: {
            ingredient: vm.edited_ingredient
          }
        }).then(function(response) {
          vm.resetData();
          $('#ingredientModal').modal('hide');
          showSuccess('Ingredient created successfully')
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      }    
    }

    vm.newIngredient = function() {
      vm.edited_ingredient = {};
      vm.errors = {};
      $('#ingredientModal').modal('show');
    }

    vm.editIngredient = function(ingredient) {
      vm.edited_ingredient = ingredient;
      vm.errors = {};
      $('#ingredientModal').modal('show');
    }

    vm.deleteIngredient = function(ingredient) {
      $http({
        url: apiUrl + 'ingredients/' + ingredient.id,
        method: 'DELETE'
      }).then(function() {
        vm.resetData();
      }).catch(function(error) {
        showError(error);
      });
    }

    infiniteScroll($http, vm, apiUrl + 'ingredients');
    loadMeasurements($http, vm);
  }

  function RecipeController($http) {
    var vm = this;

    infiniteScroll($http, vm, apiUrl + 'recipes');
    loadMeasurements($http, vm);
  };

  function SingleRecipeController($http, $stateParams) {
    var vm = this;

    // Either call the modal to create a new recipe or show what is there
    if($stateParams.create) {
      vm.newRecipe();
    } else {
      $http({
        url: apiUrl + '/recipes/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.recipe = response.data.data;
        console.log(response.data.data);
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.newRecipe = function() {

    }

  };

  angular
    .module('app.alastair_chef', [])
    .config(config)
    .controller('WelcomeController', WelcomeController)
    .controller('IngredientController', IngredientController)
    .controller('RecipeController', RecipeController)
    .controller('SingleRecipeController', SingleRecipeController);
})();

