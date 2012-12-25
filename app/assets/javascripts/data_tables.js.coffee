$ ->
  fnToDisplayColumn = (elements) ->
    a = []
    $.each elements, (index) ->
      a.push
        mDataProp: elements[index]
        bSortable: false
    return a

  fnFormatDataToDisplay = (elements) ->
    (nRow, aData, iDisplayIndex) ->
      $.each elements, (index) ->
        link = "#{elements[index]}_url"
        $("td:eq(#{index})", nRow).html "<a href='#{aData[link]}'>#{aData[elements[index]]}</a>"  if aData[link]

  oTable = $('.data_tables').dataTable
    sDom: "<'row-fluid'<'span12'l>r>t<'row-fluid'<'span6'i><'span6'p>>S"
    sPaginationType: "bootstrap"
    bProcessing: true
    bServerSide: true
    aaSorting: []
    sAjaxSource: $('.data_tables').data('source')
    aoColumns: fnToDisplayColumn($('.data_tables').data('columns'))
    fnRowCallback: fnFormatDataToDisplay($('.data_tables').data('columns'))
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
