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

  /** @ngInject */
  function config($stateProvider) {
    // State
    $stateProvider
      .state('app.alastair_shopping', {
        url: '/alastair/shopping',
        data: { pageTitle: 'Alastair Shopping View' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/shopping_view/welcome.html`,
            controller: 'WelcomeController as vm',
          },
        },
      })
      .state('app.alastair_shopping.shops', {
        url: '/shops',
        data: { pageTitle: 'Alastair Shops' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/shopping_view/shops.html`,
            controller: 'ShopsController as vm',
          },
        },
      })
      .state('app.alastair_shopping.items', {
        url: '/shops/:id',
        data: { pageTitle: 'Alastair Shopping Items' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/shopping_view/items.html`,
            controller: 'ItemsController as vm',
          },
        }
      })
      .state('app.alastair_shopping.matching', {
        url: '/shops/:id/matching',
        data: { pageTitle: 'Alastair Matching View' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/shopping_view/matching.html`,
            controller: 'MatchingController as vm',
          },
        }
      })
      .state('app.alastair_shopping.admins', {
        url: '/shops/:id/admins',
        data: { pageTitle: 'Alastair Shop Admins' },
        views: {
          'pageContent@app': {
            templateUrl: `${baseUrl}static/shopping_view/admins.html`,
            controller: 'ShopAdminsController as vm',
          },
        }
      });
  }


  function WelcomeController() {
    var vm = this;
  }

  function ShopsController($http) {
    var vm = this;

    vm.currencies = [];

    vm.loadCurrencies = function() {
      $http({
        url: apiUrl + '/currencies',
        method: 'GET'
      }).then(function(response){
        vm.currencies = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.submitForm = function() {
      // If if has an id, we should put there
      // Otherwise post
      if(vm.edited_shop.id) {
        $http({
          url: apiUrl + 'shops/' + vm.edited_shop.id,
          method: 'PUT',
          data: {
            shop: vm.edited_shop
          }
        }).then(function(response) {
          vm.resetData();
          $('#shopModal').modal('hide');
          showSuccess('Shop updated successfully')
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      } else {
        $http({
          url: apiUrl + 'shops/',
          method: 'POST',
          data: {
            shop: vm.edited_shop
          }
        }).then(function(response) {
          vm.resetData();
          $('#shopModal').modal('hide');
          showSuccess('Shop created successfully')
        }).catch(function(error) {
          if(error.status == 422)
            vm.errors = error.data.errors;
          else
            showError(error);
        });
      }    
    }

    vm.newShop = function() {
      vm.edited_shop = {
        permissions: {
          shop_admin: true
        }
      };
      vm.errors = {};
      $('#shopModal').modal('show');
    }

    vm.editShop = function(shop) {
      vm.edited_shop = shop;
      vm.errors = {};
      $http({
        url: apiUrl + '/shops/' + shop.id + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.edited_shop.permissions = {
          shop_admin: response.data.data.shop_admin,
          superadmin: response.data.data.superadmin
        };
        $('#shopModal').modal('show');
      }).catch(function(error) {
        showError();
      });

    }

    vm.deleteShop = function(shop) {
      $http({
        url: apiUrl + 'shops/' + shop.id,
        method: 'DELETE'
      }).then(function() {
        vm.resetData();
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadCurrencies();
    infiniteScroll($http, vm, apiUrl + 'shops');
  }

  function ItemsController($http, $stateParams) {
    var vm = this;

    vm.loadShop = function() {
      $http({
        url: apiUrl + 'shops/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.shop = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.deleteItem = function(item) {
      $http({
        url: apiUrl + 'shops/' + $stateParams.id + '/shopping_items/' + item.id,
        method: 'DELETE'
      }).then(function(response) {
        vm.resetData();
        showSuccess("Shopping item deleted");
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadPermissions = function() {
      return $http({
        url: apiUrl + '/shops/' + $stateParams.id + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.permissions = {
          shop_admin: response.data.data.shop_admin,
          superadmin: response.data.data.superadmin
        };
      }).catch(function(error) {
        showError();
      });
    }


    vm.loadShop();
    vm.loadPermissions();
    infiniteScroll($http, vm, apiUrl + 'shops/' + $stateParams.id + '/shopping_items');
  }

  function MatchingController($http, $stateParams, $scope) {
    var vm = this;

    vm.reset = function() {
      vm.shopping_item = {};
      $scope.$broadcast('angucomplete-alt:clearInput', 'ingredientAutocomplete');
      vm.show_help=false;
    }

    vm.loadShop = function() {
      $http({
        url: apiUrl + 'shops/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.shop = response.data.data;
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadPermissions = function() {
      return $http({
        url: apiUrl + '/shops/' + $stateParams.id + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.permissions = {
          shop_admin: response.data.data.shop_admin,
          superadmin: response.data.data.superadmin
        };
      }).catch(function(error) {
        showError();
      });
    }


    vm.applyIngredient = function(selected) {
      if(selected) {
        vm.shopping_item.mapped_ingredient = selected.originalObject;
        vm.shopping_item.mapped_ingredient_id = selected.originalObject.id;
      }
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

    vm.submitForm = function() {
      $http({
        url: apiUrl + '/shops/' + $stateParams.id + '/shopping_items',
        method: 'POST',
        data: {
          shopping_item: vm.shopping_item
        }
      }).then(function(response) {
        showSuccess("Shopping item saved, you can continue matching!");
        vm.reset();
      }).catch(function(error) {
        if(error.status == 422) 
          vm.errors = error.data.errors;
        else
          showError(error);
      });
    }

    vm.reset();
    vm.loadShop();
    vm.loadPermissions();
  }

  function ShopAdminsController($http, $stateParams) {
    var vm = this;

    vm.permissions = {
      shop_admin: true
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
        url: apiUrl + '/shops/' + $stateParams.id + '/user',
        method: 'GET'
      }).then(function(response) {
        vm.permissions = {
          shop_admin: response.data.data.shop_admin,
          superadmin: response.data.data.superadmin
        };
      }).catch(function(error) {
        showError();
      });
    }


    vm.loadAdmins = function(callback) {
      return $http({
        url: apiUrl + '/shops/' + $stateParams.id + '/admins',
        method: 'GET'
      }).then(function(response) {
        vm.admins = response.data.data;
        if(callback)
          callback();
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.loadShop = function(callback) {
      $http({
        url: apiUrl + '/shops/' + $stateParams.id,
        method: 'GET'
      }).then(function(response) {
        vm.shop = response.data.data;
        if(callback)
          callback();
      }).catch(function(error) {
        showError(error);
      });
    }

    vm.deleteAdmin = function(user) {
      return $http({
        url: apiUrl + '/shops/' + $stateParams.id + '/admins/' + user.id,
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
        url: apiUrl + '/shops/' + $stateParams.id + '/admins/',
        method: 'POST',
        data: {
          shop_admin: user.originalObject
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
    vm.loadShop();
  }

  angular
    .module('app.alastair_shopping', [])
    .config(config)
    .controller('WelcomeController', WelcomeController)
    .controller('ShopsController', ShopsController)
    .controller('ItemsController', ItemsController)
    .controller('MatchingController', MatchingController)
    .controller('ShopAdminsController', ShopAdminsController);
})();

