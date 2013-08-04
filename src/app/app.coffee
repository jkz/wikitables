# Create all modules here

angular.module '', [
  'templates-app',
  'templates-common',

  'ui.state',
  'ui.route',
  'ui.event',
  'ui.keypress',

  'ngCookies',
  'titleService',
  'urlencode-POST',

  'kit',
  'markdown',
  'fuzzy',

  'github'
]

# This is for Angular < 1.1
# for more info see:
# http://stackoverflow.com/questions/16661032/http-get-is-not-allowed-by-access-control-allow-origin-but-ajax-is
.config ($httpProvider) ->
  delete $httpProvider.defaults.headers.common['X-Requested-With']

.config ($stateProvider, $urlRouterProvider) ->

  # All non matching paths are redirected to /404.
  $urlRouterProvider
    .otherwise '/404'

  $stateProvider
    .state '404',
      url: '/404'
      templateUrl: '404.tpl.html'

.run ($rootScope, $state, $stateParams) ->
  # Expose state parameters to the scope
  $rootScope.$state = $state
  $rootScope.$stateParams = $stateParams

.controller 'AppCtrl', ($scope, $rootScope) ->
  # pass

