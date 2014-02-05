function loadChart(rows, size){
// Load the Visualization API and the piechart package.
google.load('visualization', '1.0', {'packages':['corechart']});

// Set a callback to run when the Google Visualization API is loaded.
google.setOnLoadCallback(drawChart);

// Callback that creates and populates a data table, 
// instantiates the pie chart, passes in the data and
// draws it.
function drawChart() {

	 // Create the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'options');
    data.addColumn('number', '# votes');
    data.addRows(rows);

    // Set chart options
    var options = {'title':'survey results',
                   'width': 150 * size,
                   'height':300, 
					 'vAxis': { 
						'minValue': 0.0 
						} 
					};

    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.ColumnChart(document.getElementById('chart'));
    chart.draw(data, options);
	}
}