'use strict';

$(document).ready(function() {
    var allMsgs;
    $.getJSON('results.json', function(data) {
        allMsgs = data;
        var stockBox = $('#messages');
        var allMsgKeys = Object.keys(allMsgs).reverse();
        console.log(allMsgs['0']);

        for (var i = 0; i < allMsgKeys.length; i++) {
          var info = allMsgs[i];

          var msgLink = $(document.createElement('a'));
          // set url
          msgLink.attr("href", info.url);

          var nextMsg = $(document.createElement('div'));
          msgLink.append(nextMsg);
          nextMsg.text("hellosdfs world");
          nextMsg.addClass("message");

          stockBox.append(msgLink);

        }









    });
});
