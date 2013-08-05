angular.module('wikitables')

.service('wikitables', ($http) ->
  wikitables =
    get: (page) ->
      $http.jsonp(
        'http://en.wikipedia.org/w/api.php?callback=JSON_CALLBACK', {
          params:
            format: 'json'
            action: 'parse'
            page: page
        }
      )

  linkmark = /\s*\[[^\]]\]\s*$/i

  parse =
    cell: (cell) ->
      # Add all value columns to the row (so don't add the key column)
      text = $.trim(cell.text())

      # '?' cells are set to undefined
      if not text or text == '?'
        return

      while linkmark.test(text)
        text = text.replace linkmark, ''

      if cell.hasClass 'table-yes'
        color = 'success'
      else if cell.hasClass 'table-partial'
        color = 'warning'
      else if cell.hasClass 'table-no'
        color = 'danger'
      else if cell.hasClass 'table-unknown'
        color = 'unknown'

      return text: text, color: color

  parse.array = (table) ->
    rows = {}

    $(table).find('tbody').children().each (index, tr) ->
      tr = $(tr)

      if not index or not tr.hasClass 'sortable'
        # Select all direct children (wikis are not to be trusted to provide
        # the excepted tags)
        tds = tr.children()

        # The first row contains the headers and has '' as key
        # The other rows have their identifier as key
        key = if index then tds.first().text() else ''

        # Add a new row for the key
        rows[key] = []
        tds.each (i, td) ->
          td = $(td)
          # Add all value columns to the row (so don't add the key column)
          if i
            rows[key].push wikitables.parse.cell td
        console.log tds.length

    return rows

  parse.object = (table) ->
    columns = []
    rows = {}
    $(table).find('tbody').children().each (index, tr) ->
      tr = $(tr)

      if not index or not tr.hasClass 'sortable'
        # Select all direct children (wikis are not to be trusted to provide
        # the excepted tags)
        tds = tr.children()

        # The first iteration is over the table header and puts the given
        # keys in an array
        if not index
          tds.each (i, td) ->
            if i
              columns.push($(td).text())

        # The other iterations build objects with the keys taken above
        else
          key = tds.first().text()

          rows[key] = {}

          tds.each (i, td) ->
            if i
              rows[key][columns[i - 1]] = parse.cell $(td)

    return columns: columns, rows:rows

  join =
    array: (tables) ->
      # The container for final joined row data. New rows are inserted
      # by their keys, their values are arrays which get extended
      rows = {}

      # The left-padding for newly added keys as an array of undefineds
      prefix = []

      for table in tables
        for key, row of table
          # Add the new values to existing row
          if rows[key]
            rows[key] = rows[key].concat row

          # Create a new row with prefix undefineds padding
          else
            rows[key] = prefix.concat row

        # Get the length of this table by the column keys row
        len = table[''].length

        # The right-padding for unupdated keys
        suffix = (undefined for i in [0...table[''].length])

        for key of rows
          # Add the right padding to unupdated rows
          if not table[key]
            rows[key] = rows[key].concat suffix

        # Update the prefix with to match the current size
        prefix = prefix.concat suffix

      arrayRows = []

      for key, row of rows
        arrayRows.push([key].concat row)

      return arrayRows

    object: (tables) ->
      columns = []
      rows = {}
      # Concatenate all key arrays and extend all row objects
      for table in tables
        columns = columns.concat(table.columns)
        for key, row of table.rows
          rows[key] = angular.extend(rows[key] or {}, row)

      objectRows = []

      for key, row of rows
        row[''] = text: key
        objectRows.push(row)

      return columns: columns, rows: objectRows

  wikitables.build = (text, type = 'object') ->
    tables = []
    element = $('<div>')
    element
    .html(text)
    .find('.wikitable').each (index, table) ->
      rows = parse[type] table
      tables.push rows
    console.log 'join', join
    join[type] tables

  wikitables.parse = parse
  wikitables.join = join

  return wikitables
)

.controller('WikiCtrl', ($scope, $rootScope, wikitables, $http, $stateParams) ->
  $scope.table = undefined

  wikitables.get($stateParams.page)
  .success (data) ->
    if data
      $rootScope.title = data.parse.title
      $scope.table = wikitables.build data.parse.text['*']
      console.log $scope.table
)
