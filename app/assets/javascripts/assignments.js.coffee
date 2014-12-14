ready = ->
  ctx = $("#chart").get(0).getContext("2d")

  options =
    scaleShowGridLines : true,
    scaleGridLineColor : "rgba(0,0,0,.05)",
    scaleGridLineWidth : 1,
    bezierCurve : true,
    bezierCurveTension : 0.4,
    pointDot : true,
    pointDotRadius : 4,
    pointDotStrokeWidth : 1,
    pointHitDetectionRadius : 20,
    datasetStroke : true,
    datasetStrokeWidth : 2,
    datasetFill : true,
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

  assignment_id = $("#assignment-name").attr("assignment-id")
  $.get "/assignments/data/" + assignment_id, (data) ->
    labels = []
    values = []
    
    for k of data.data
      labels.push(k)
      values.push(data.data[k])
      
    dates = []
    for l in labels
      date = Date.parseExact(l, 'yyyMMdd HH')
      dates.push(date.getHours() + ":00")
    
    chartdata =
      labels: dates
      datasets: [
          {
              label: "Submissions by hour",
              fillColor: "rgba(151,187,205,0.2)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#fff",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: values
          }
      ]
      # labels: ["January", "February", "March", "April", "May", "June", "July"],
      # datasets: [
      #     {
      #         label: "My First dataset",
      #         fillColor: "rgba(220,220,220,0.2)",
      #         strokeColor: "rgba(220,220,220,1)",
      #         pointColor: "rgba(220,220,220,1)",
      #         pointStrokeColor: "#fff",
      #         pointHighlightFill: "#fff",
      #         pointHighlightStroke: "rgba(220,220,220,1)",
      #         data: [65, 59, 80, 81, 56, 55, 40]
      #     },
      #     {
      #         label: "My Second dataset",
      #         fillColor: "rgba(151,187,205,0.2)",
      #         strokeColor: "rgba(151,187,205,1)",
      #         pointColor: "rgba(151,187,205,1)",
      #         pointStrokeColor: "#fff",
      #         pointHighlightFill: "#fff",
      #         pointHighlightStroke: "rgba(151,187,205,1)",
      #         data: [28, 48, 40, 19, 86, 27, 90]
      #     }
      # ]

    chart = new Chart(ctx).Line(chartdata, options)

$(document).ready(ready);
$(document).on('page:load', ready);