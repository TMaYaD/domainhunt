$ ->
  fnToDisplayColumn = (elements) ->
    a = []
    $.each elements, (index) ->
      a.push mDataProp: elements[index]
    return a

  fnFormatDataToDisplay = (elements) ->
    (nRow, aData, iDisplayIndex) ->
      $.each elements, (index) ->
        link = "#{elements[index]}_url"
        $("td:eq(#{index})", nRow).html "<a href='#{aData[link]}'>#{aData[elements[index]]}</a>"  if aData[link]

  $('.data_tables').dataTable
    sDom: "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>S"
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
