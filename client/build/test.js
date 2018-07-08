'use strict';

$(document).ready(function() {
    var allMsgs;
    $.getJSON('results.json', function(data) {
      function createDivClassText ({ body, classs }) {
        var div = $(document.createElement('div'));
        div.text(body);
        div.addClass(classs);
        return div;
      }
      function createDateNTime ({ createdAt, ticker }) {
        var options = { month: 'long', day: 'numeric',
                        hour: 'numeric', minute: 'numeric' };
        var dateFormatter = new Intl.DateTimeFormat('en-US', options)
        var time = new Date(createdAt);
        var timeStamp = dateFormatter.format(time);
        // var timeStamp = time.toLocaleFormat('%B, %d , %H, %M');

        var details = $(document.createElement('div'));
        details.addClass('details');

        var date = createDivClassText({ body: timeStamp, classs: 'date' });
        var ticker = createDivClassText({ body: ticker, classs: 'ticker' });
        details.append(ticker);
        details.append(date);

        return details;
      }


// =[=====================================]

        allMsgs = data;
        var stockBox = $('#messages');
        var allMsgKeys = Object.keys(allMsgs).reverse();
        console.log(allMsgs['0']);

        for (var i = 0; i < allMsgKeys.length; i++) {
          var key = allMsgKeys[i];
          var info = allMsgs[key];

          var msgLink = $(document.createElement('a'));
          msgLink.addClass("not-link");
          // set url...create message box
          msgLink.attr("href", info.url);
          var nextMsg = $(document.createElement('div'));
          msgLink.append(nextMsg);
          nextMsg.addClass("message");

          // set color
          var red = '#edb8b8';
          var green = '#beeaa6';
          var sentiment = info.sentiment;
          if (sentiment == 'Bullish') {
            nextMsg.css('background-color', green);
          } else if (sentiment == 'Bearish') {
            nextMsg.css('background-color', red);
          }

          // append Ticker + Date box
          nextMsg.append(createDateNTime({ createdAt: info.created_at, ticker: info.ticker }));

          // append Msg Body
          var unsanitizedBody = info.body.replace(/_/g,' ');
          nextMsg.append(createDivClassText({ body: unsanitizedBody, classs: 'brag-box' }));
          stockBox.append(msgLink);

        }









    });
});
