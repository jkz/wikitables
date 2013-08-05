# Create all modules here

angular.module('wikitables', [
  'templates-app'
  'templates-common'

  'ui.state'
  'ui.route'
])

.service '_', ($window) ->
  $window._


.config ($stateProvider, $urlRouterProvider) ->
  # All non matching paths are redirected to /404.
  $urlRouterProvider
    .otherwise '/404'

  $stateProvider
    .state '404',
      url: '/404'
      templateUrl: '404.tpl.html'
    .state 'page',
      url: '/:page'
      controller: 'WikiCtrl'
      templateUrl: 'wiki/table.tpl.html'
    .state 'welcome',
      url: '/'
      controller: 'WikiCtrl'
      templateUrl: 'wiki/table.tpl.html'

.run ($rootScope, $state, $stateParams) ->
  # Expose state parameters to the scope
  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams
