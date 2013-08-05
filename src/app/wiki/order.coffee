angular.module('wikitables')
.directive('ordered', ($filter) ->
  restrict: 'A'
  link: ($scope) ->
    order =
      columns: []
      predicates: {}
      getters: []

    order.update = (column) ->
      (obj) ->
        obj[column]?.content

    order.promote = (column) ->
      # Ugily move the predicate to front
      columns = order.columns
      order.columns = [column]
      for p in columns
        if p isnt column
          order.columns.push p

    order.toggle = (column) ->
      order.predicates[column] = \
        if order.predicates[column] == '↓' then '↑' else '↓'

    order.remove = (column) ->
      # Ugily rebuild the predicates without given predicate
      columns = order.columns
      order.columns = []
      for p in columns
        if p isnt column
          order.columns.push p
      delete order.predicates[column]

    order.add = (column) ->
      order.promote column
      order.toggle column

    order.reset = ->
      order.predicates = {}
      order.columns = []
      order.add ''

    order.filter = (data) ->
      for column in order.columns[..].reverse()
        data = $filter('orderBy')(data, ((obj) -> obj[column]?.content),
          order.predicates[column] == '↑')
      return data

    order.reset()

    $scope.order = order
)
