'use strict';

$(document).ready(function() {
    var myItems;

    $.getJSON('results.json', function(data) {
        myItems = data;
        console.log(myItems);
    });
});
