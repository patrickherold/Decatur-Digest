# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).closest('.field').remove()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

    
    Morris.Bar
      element: 'lots_chart'
      data: $('#lots_chart').data('lots')
      xkey: 'zoning'
      ykeys: ['appraised_value', 'appeal_value', 'taxable']
      labels: ['Appraised Value', 'Appeal Value', 'Taxable']
      preUnits: '$'