angular.module('wikitables')
.directive('filtered', ->
  restrict: 'A'
  link: ($scope) ->
    filter:
      AND: -> (left, right) ->
        (data) ->
            left(data) && right(data)

      OR: -> (left, right) ->
        (data) ->
            left(data) || right(data)

    class Filter
      constructor: (@column, @value) ->

      run: (row) ->
        @cmp row[column]

      cmp: (val) ->
        true


    class eq extends Filter
      cmp: (val) ->
        val is @val

    class gt extends Filter
      cmp: (val) ->
        val > @val

    class gte extends Filter
      cmp: (val) ->
        val >= @val

    class lt extends Filter
      cmp: (val) ->
        val < @val

    class lte extends Filter
      cmp: (val) ->
        val <= @val

    class regex extends Filter
      cmp: (val) ->
        @val.test(val)

)