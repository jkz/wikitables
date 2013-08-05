angular.module('wikitables')
.directive('ordered', ->
  restrict: 'A'
  link: ($scope) ->
    $scope.predicates = []

    orderGetter = ->
      getters = []
      for p in $scope.predicates
        ((scoped_p) ->
          getters.push (obj) ->
            obj[scoped_p]?.text
        )(p)
      $scope.predicateGetters = getters

    $scope.orderSetter = (predicate) ->
      # Ugily move the predicate to front
      console.log 'predicate', predicate
      predicates = $scope.predicates
      $scope.predicates = [predicate]
      for p in predicates
        if p isnt predicate
          $scope.predicates.push p
      orderGetter()

    $scope.orderSetter ''
)
