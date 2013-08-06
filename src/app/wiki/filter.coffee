angular.module('wikitables')
.directive('filtered', ->
  restrict: 'A'
  link: ($scope) ->
    filters =
      all: []
      new: {}
      regex: {}

    filters.add = ->
      filters.all.push filters.new
      filters.new = {}

    filters.execute =
      one: (f, row) ->
        if filters.comperators[f.cmp]? row[f.column]?.content, f.value
          not f.not
        else
          f.not

    filters.build = (column, cmp, val) ->
      filters.all.push (row) ->
        cmp row[column]?.content, val

    filters.remove = (index) ->
      filters.all = filters.all.splice index, 1

    filters.comperators =
      'equals': (x, y) -> x == y
      #XXX this is far from optimal
      'matches': (x, y) -> new RegExp(y).test(x)
      '>': (x, y) -> x > y
      '>=': (x, y) -> x >= y
      '<': (x, y) -> x < y
      '<=': (x, y) -> x <= y

    filters.connectives =
      AND: (x, y) -> (z) -> x z and y z
      OR: (x, y) -> (z) -> x z or y z

    filters.execute.all = (row) ->
      for filter in filters.all
        if not filters.execute.one(filter, row)
          return false
      return true

    filters.reset = ->
      filters.all = []

    $scope.filters = filters
)
.directive('filter', ->
  restrice: 'A'
  templateUrl: 'wiki/filter.tpl.html'
  scope:
    filter: '='
)