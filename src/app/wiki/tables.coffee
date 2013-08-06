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

  re =
    number: /^\d*(,\d\d\d)*\+?$/
    annotation: /\s*\[([^\]]+)\]\s*$/i
    note: /n (\d)+/
    link: /\d+/

  parse =
    cell: (cell) ->
      # Integer columns seem to have an incisiable span that messes up the
      # value. We remove those here
      cell.find('span[style="display:none"]').remove()

      # Start off with the trimmed text
      original = $.trim(cell.text())
      content = original

      # empty and '?' cells are set to undefined
      if not content or content == '?'
        return

      # Annotations like [1] and [n 23] are removed from the content here
      #TODO parse the annotations and add them to the cell
      annotations =
        links: []
        notes: []
      while re.annotation.test(content)
        annotation = parseInt re.annotation.exec(content)[1]
        #TODO match various link types and add them to `links`
        content = content.replace re.annotation, ''

      # First check for date values
      # Numerical values are stored as integer rather than strings
      #TODO support floating point numbers
      if re.number.test content
        text = parseInt content.replace /,/, ''

      # The cell class is inspected for colors
      if cell.hasClass 'table-yes'
        color = 'success'
      else if cell.hasClass 'table-partial'
        color = 'warning'
      else if cell.hasClass 'table-no'
        color = 'danger'
      else if cell.hasClass 'table-unknown'
        color = 'unknown'

      content: content
      color: color
      annotations: annotations
      original: original

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
            rows[key].push wikitables.parse.cell t

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
              # Column indices are 1 behind row indices because of pk
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
        row[''] = content: key
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

.controller('WikiCtrl', ($scope, $rootScope, wikitables, $stateParams) ->
  $scope.table = undefined

  wikitables.get($stateParams.page)
  .success (data) ->
    if data
      $rootScope.title = data.parse.title
      $scope.table = wikitables.build data.parse.text['*']
      $scope.links = data.parse.externallinks
      console.log data.parse
)
