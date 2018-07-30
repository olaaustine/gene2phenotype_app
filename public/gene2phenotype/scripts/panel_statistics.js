$( document ).ready(function() {
  google.charts.load('current', {'packages':['bar']});

  if (document.getElementById('barchart_material')) {
    google.charts.setOnLoadCallback(drawChart);
  }

  function drawChart() {
    var div = document.getElementById('barchart_material');
    var input_data = JSON.parse(div.getAttribute('data'));
    var data = google.visualization.arrayToDataTable(input_data);
    var options = {
      chart: {
        title: 'G2P panels and gene counts for each confidence level',
      },
      bars: 'horizontal' // Required for Material Bar Charts.
    };

    var chart = new google.charts.Bar(document.getElementById('barchart_material'));

    chart.draw(data, google.charts.Bar.convertOptions(options));
  }
});
