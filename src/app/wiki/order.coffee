angular.module('wikitables')
.directive('ordered', ->
  restrict: 'A'
  link: ($scope) ->
    order =
      predicates: []
      getters: []

    order.update = ->
      order.getters = []
      for p in order.predicates
        ((scoped_p) ->
          order.getters.push (obj) ->
            obj[scoped_p]?.content
        )(p)

    order.add = (predicate) ->
      # Ugily move the predicate to front
      predicates = order.predicates
      order.predicates = [predicate]
      for p in predicates
        if p isnt predicate
          order.predicates.push p
      order.update()

    order.remove = (predicate) ->
      # Ugily rebuild the predicates without given predicate
      predicates = order.predicates
      order.predicates = []
      for p in predicates
        if p isnt predicate
          order.predicates.push p
      order.update()

    order.reset = ->
      order.predicates = []
      order.add ''

    order.reset()

    $scope.order = order
)
