angular.module('wikitables')
.directive('displayed', ->
  restrict: 'A'
  link: ($scope) ->
    display =
      hidden: {}

    display.show = (column) ->
      delete display.hidden[column]

    display.hide = (column) ->
      display.hidden[column] = true

    display.reset = ->
      display.hidden = {}

    display.reset()

    $scope.display = display
)

