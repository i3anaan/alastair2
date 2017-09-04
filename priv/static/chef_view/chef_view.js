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
      .state('app.alastair_chef.my_recipes', {
        url: '/my_recipes',
        data: { pageTitle: 'Alastair My Recipes' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/my_recipes.html`,
            controller: 'MyRecipesController as vm'
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
      })
      .state('app.alastair_chef.admins', {
        url: '/admins',
        data: { pageTitle: 'Alastair Admins' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/chef_view/admins.html`,
            controller: 'AdminsController as vm'
          }
        }
      })
  }


  function WelcomeController() {
    var vm = this;
  }

  function IngredientController($http) {
    var vm = this;

    // TODO fetch permissions from backend
    vm.permissions = {
      superuser: false
    };


    vm.measurements = [];

    vm.loadPermissions = function() {
      return $http({
        url: apiUrl + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.permissions.superuser = response.data.data.superadmin;
      }).catch(function(error) {
        showError();
      });
    }

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
    vm.loadPermissions();
  }

  function RecipeController($http) {
    var vm = this;

    infiniteScroll($http, vm, apiUrl + 'recipes');
    loadMeasurements($http, vm);
  }

  function SingleRecipeController($scope, $http, $stateParams, $state, $rootScope) {
    var vm = this;

    vm.permissions = {
      edit_recipe: true,
      delete_recipe: true
    }

    vm.review = {
      rating: 1,
      review: null
    }

    vm.create = $stateParams.create || $stateParams.id == 'new';

    vm.loadRecipe = function(id) {
      $http({
        url: apiUrl + '/recipes/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.recipe = response.data.data;
        // Check if we already reviewed this recipe
        vm.our_review = vm.recipe.reviews.find((item) => {return item.user_id == $rootScope.currentUser.id});
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.newRecipe = function() {
      $('#recipeModal').modal('show');
      vm.recipes_ingredients_error_offset = 0;
      if(!vm.create || !vm.edited_recipe)
        vm.edited_recipe = {
          recipes_ingredients: []
        };
      vm.errors = {};
    }

    vm.editRecipe = function() {
      $('#recipeModal').modal('show');
      vm.recipes_ingredients_error_offset = vm.recipe.recipes_ingredients.length;
      vm.edited_recipe = angular.copy(vm.recipe);
      vm.errors = {};
    }

    vm.submitForm = function() {
      // If it has an id POST, otherwise PUT
      if(vm.edited_recipe.id) {
        $http({
          url: apiUrl + '/recipes/' + vm.edited_recipe.id,
          method: 'PUT',
          data: {
            recipe: vm.edited_recipe
          }
        }).then(function(response) {
          vm.recipe = response.data.data;
          showSuccess('Recipe saved successfully');
          $('#recipeModal').modal('hide');
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      } else {
        $http({
          url: apiUrl + '/recipes/',
          method: 'POST',
          data: {
            recipe: vm.edited_recipe
          }
        }).then(function(response) {
          $('#recipeModal').modal('hide');
          $state.go('app.alastair_chef.single_recipe', {id: response.data.data.id, create: false});
          showSuccess('Recipe saved successfully');          
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      }
    }

    vm.deleteRecipe = function() {
      $http({
        url: apiUrl + '/recipes/' + $stateParams.id,
        method: 'DELETE'
      }).then(function(response) {
        $state.go('app.alastair_chef.my_recipes');
        showSuccess('Recipe deleted successfully');          
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.publishRecipe = function() {
      vm.edited_recipe = angular.copy(vm.recipe);
      vm.edited_recipe.published = true;
      vm.submitForm();
    }

    vm.addToMeal = function() {
      $.gritter.add({
        title: 'Not yet implemented',
        text: 'Go beat up the developers for being lazy',
        sticky: false,
        time: 8000,
        class_name: 'my-sticky-class',
      });
    }

    vm.addIngredient = function(ingredient) {
      vm.edited_recipe.recipes_ingredients.push({
        quantity: 0,
        ingredient_id: ingredient.originalObject.id,
        ingredient: ingredient.originalObject
      });
      $scope.$broadcast('angucomplete-alt:clearInput', 'ingredientAutocomplete');
    }

    vm.fetchIngredients = function(query, timeout) {
      // Copied from the angular tutorial on how to add transformations
      function appendTransform(defaults, transform) {
        // We can't guarantee that the default transformation is an array
        defaults = angular.isArray(defaults) ? defaults : [defaults];

        // Append the new transformation to the defaults
        return defaults.concat(transform);
      }

      return $http({
        url: apiUrl + '/ingredients',
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

    vm.sendReview = function() {
      $http({
        url: apiUrl + `recipes/${$stateParams.id}/reviews`,
        method: 'POST',
        data: {
          review: vm.review
        }
      }).then(function(response) {
        vm.loadRecipe();
        showSuccess("Review created successfully");
      }).catch(function(error) {
        showError(error);
      })
    }

    vm.deleteReview = function() {
      $http({
        url: apiUrl + `recipes/${$stateParams.id}/reviews/${vm.our_review.id}`,
        method: 'DELETE'
      }).then(function(response) {
        vm.loadRecipe();
        showSuccess("Review retracted successfully");
      }).catch(function(error) {
        showError(error);
      });
    }

    // Either call the modal to create a new recipe or show what is there
    if(vm.create) {
      vm.newRecipe();
    } else {
      vm.loadRecipe();
    }
  }

  function MyRecipesController($http) {
    var vm = this;

    infiniteScroll($http, vm, apiUrl + 'my_recipes');
    loadMeasurements($http, vm);
  }

  function AdminsController($http) {
    var vm = this;

    vm.permissions = {
      superuser: false
    };

    vm.busy = true;

    vm.fetchUsers = function(query, timeout) {
      // Copied from the angular tutorial on how to add transformations
      function appendTransform(defaults, transform) {
        // We can't guarantee that the default transformation is an array
        defaults = angular.isArray(defaults) ? defaults : [defaults];

        // Append the new transformation to the defaults
        return defaults.concat(transform);
      }

      return $http({
        url: '/api/users',
        method: 'GET',
        params: {
          limit: 8,
          name: query
        },
        transformResponse: appendTransform($http.defaults.transformResponse, function (res) {
          if(res && res.data)
            return res.data.map(function(item) {
              item.name = item.first_name + ' ' + item.last_name;
              item.user_id = '' + item.id;
              delete item.id;
              return item;
            });
          else
            return [];
        }),
        timeout: timeout,
      });
    }

    vm.loadPermissions = function() {
      return $http({
        url: apiUrl + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.permissions.superuser = response.data.data.superadmin;
      }).catch(function(error) {
        showError();
      });
    }


    vm.loadAdmins = function(callback) {
      return $http({
        url: apiUrl + '/admins',
        method: 'GET'
      }).then(function(response) {
        vm.admins = response.data.data;
        if(callback)
          callback();
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.deleteAdmin = function(user) {
      return $http({
        url: apiUrl + '/admins/' + user.id,
        method: 'DELETE'
      }).then(function(response) {
        vm.loadAdmins(function() {
          showSuccess("User removed as admin");
        });
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.addAdmin = function(user) {
      return $http({
        url: apiUrl + '/admins/',
        method: 'POST',
        data: {
          admin: user.originalObject
        }
      }).then(function(response) {
        vm.loadAdmins(function() {
          showSuccess("User added as admin");
        })
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadAdmins(function() {vm.busy = false;});
    vm.loadPermissions();
  }

  function StarRatingDirective() {
    function link(scope) {
      scope.range = function(items) {
        if(items >= 0.5){
          items = Math.round(items);
          return new Array(items);
        }
        else
          return [];
      }
    }

    return {
      templateUrl: baseUrl + 'static/chef_view/star_rating_directive.html',
      restrict: 'E',
      scope: {
        score: '=',
        max: '=',
      },
      link: link
    }
  }

  angular
    .module('app.alastair_chef', [])
    .config(config)
    .controller('WelcomeController', WelcomeController)
    .controller('IngredientController', IngredientController)
    .controller('RecipeController', RecipeController)
    .controller('SingleRecipeController', SingleRecipeController)
    .controller('MyRecipesController', MyRecipesController)
    .controller('AdminsController', AdminsController)
    .directive('omsStarRating', StarRatingDirective);
})();

