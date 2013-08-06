angular.module('wikitables')
.directive('filtered', ->
  restrict: 'A'
  controller: ($scope, $rootScope) ->
    wikiyes =
      column: 'Wiki'
      cmp: 'equals'
      value: 'Yes'

    wikimore =
      left: wikiyes
      right: {}
      gate: undefined

    wikimost =
        left: wikimore
        right: {}
        gate: 'AND'

    filters =
      root: wikimore
      tests:
        'equals': (x, y) -> x == y
        #XXX this is far from optimal
        'matches': (x, y) -> new RegExp(y).test(x)
        '>': (x, y) -> x > y
        '>=': (x, y) -> x >= y
        '<': (x, y) -> x < y
        '<=': (x, y) -> x <= y
      gates:
        AND: (x, y) -> x and y
        OR: (x, y) -> x or y
        XOR: (x, y) -> if x then not y else y

    filters.reset = ->
      filters.root = {}

    filters.node = (left, right, gate) ->
      left: left or {}
      right: right or {}
      gate: gate

    filters.insert = (old, gate) ->
      console.log 'INSERT', old, gate
      old.left = filters.node old.left, old.right, old.gate
      old.right = filters.node()
      old.gate = gate

    filters.pluck = (branch, side) ->
      branch[side] = {}

    filters.resolve =
      leaf: (f, row) ->
        if f is undefined or not f.cmp
          return true
        else
          cmp = filters.tests[f.cmp]
          col = row[f.column]
          if cmp and col and cmp col.content, f.value
            return not f.not
        f.not

    filters.resolve.tree = (root, row) ->
      if not root.gate
        left = filters.resolve.leaf root.left, row
        right = filters.resolve.leaf root.right, row
        left and right
      else
        left = filters.resolve.tree root.left, row
        right = filters.resolve.tree root.right, row
        filters.gates[root.gate] left, right

    filters.execute = (row) ->
      filters.resolve.tree filters.root, row

    $scope.filters = filters
)

.directive('filterTree', ($compile) ->
  restrict: 'E'
  templateUrl: 'wiki/filter/tree.tpl.html'
  scope:
    filters: '='
    table: '='
    node: '='
  compile: (tElement, tAttr) ->
    contents = tElement.contents().remove()
    (scope, iElement, iAttr) ->
      unless compiledContents
        compiledContents = $compile(contents)
      compiledContents scope, (clone, scope) ->
        iElement.append(clone)
)

.directive('filterBranch', ->
  restrict: 'E'
  templateUrl: 'wiki/filter/branch.tpl.html'
  scope:
    filters: '='
    table: '='
    node: '='
)

.directive('filterLeaf', ->
  restrict: 'E'
  templateUrl: 'wiki/filter/filter.tpl.html'
  scope:
    filters: '='
    table: '='
    node: '='
  controller: ($scope) ->
    $scope.filter = $scope.node?.left or $scope.node?.right
)