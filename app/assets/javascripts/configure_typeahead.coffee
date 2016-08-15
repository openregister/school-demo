$(document).ready ->
  input = $('#search .typeahead')
  host = input.data('host')
  items = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: host + '/items/%QUERY'
      wildcard: '%QUERY')
  input.typeahead({
    hint: true
    highlight: true
    minLength: 2
  },
    display: 'name'
    limit: 10
    source: items).bind 'typeahead:selected', (obj, datum, name) ->
    window.location.href = '/points/' + datum.point
    return
  return
