$ ->
  fnToDisplayColumn = (elements) ->
    a = []
    $.each elements, (index) ->
      a.push
        mDataProp: elements[index]
        bSortable: false
    return a

  oTable = $('.data_tables').dataTable
    sDom: "<'row-fluid'<'span12'l>r>t<'row-fluid'<'span6'i><'span6'p>>S"
    sPaginationType: "bootstrap"
    bProcessing: true
    bServerSide: true
    aaSorting: []
    sAjaxSource: $('.data_tables').data('source')
    iDisplayLength: 20
    bLengthChange: false
    bDeferRender: true
    sScrollY: '500px'
    iScrollLoadGap: '100px'
    fnServerParams: (aoData)->
      formData = $('form').serializeArray()
      $.each formData, (i)->
        aoData.push formData[i]

      aoData

  $('form').on 'change', ->
    oTable.fnDraw()

  $('.data_tables').on 'ajax:success', 'a[data-remote=true]', ->
    oTable.fnDraw()
