### Introduction. 05.09.2022

Fetches every message on  Stocktwits.com for the top 1200 Nasdaq/NYSE stocks by volume from some random day in March.   
Was originally going to try and do some machine learning, but the posts on stocktwats are so short/garbage/spammy, I figure its not worth it.

Instead, we can do a simple find operation on all the messages.

### Example Use-case

Messages where people have said "told you so" to find spots where people are bragging about making money, and haven't yet sold.

### Dependencies for ubuntu

You need to install jq, mailutils, and moreutils.  Here are the commands for Debien.  

```bash
$ sudo apt-get update
$ sudo apt-get install jq
$ sudo apt-get install mailutils
$ sudo apt-get install moreutils
```

### Usage

Change lines 4 and 5 of fetch_messages.sh.  MY_PHRASE are the keywords you're looking for.


eg...
```bash
#  fetch_messages.sh
EMAIL=bob.bill@gmail.com
MY_PHRASE="told you so"
```

Make script executable
```bash
$ chmod +X [PATH_TO]/fetch_messages.sh
```

Next.  Setup a cron job on ec2 or your own system.
Here's the quick and dirty to setup the cron job.
```bash
$ crontab -e
# Now pick an editor and add this at the end of crontab.  This will run the script on the 35th minute of every hour, and send you an email whenever someone says "told you so on stocktwats"

GNU nano 2.5.3                     File: /tmp/crontab.tDOnHq/crontab
35 */1 * * * /[YOUR_PATH_TO_]/fetch_messages.sh
```


### Improvements

1) Rank stocks by number of followers.  Again take the list of 2000, and go with the top 400 most followed.  This would be a better proxy for finding stocks with high volume of twits.

3) Also seems like we could remove things like auto posted content.  Links.  Other garbage posts.  There are some bots who post.  Come up with a list of usernames that spam, and get rid of their posts.

4) Sometimes people will bull about a stock and post it on a different stocks board to generate attention.  These people should die.  But no really.  A quick solution is to delete posts that mention other tickers.  A better way would be to regex for the ticker they are talking about and then use that as the ticker.

5) Bragging posts seem very far and few between to do this project on.  Maybe we could do some sort of sentiment analysis.  Extreme bullish/bearish.  Moderate.  Unsure.  Jubillance, Desperation.

6) Read through the posts as we get them to generate some ideas.  Ideally an end result is to store the sentiment classifier in a new column.  Then store this data somewhere, probably postgres and cool infoprmation to the frontend.  Until we decide what that information is, its kinda hard to start work on the frontend.  Hint hint, get moving.

7) Any sort of happiness in the comments really.4

8) Deep learning to detect spammers and automatically add their usernames to a block list.

10) jupyter notebook to massage the data.  First eliminating the spammers.

11) Im seeing emotion v non-emotion.  The bragging thing can wait maybe.  Then we can do some sort of combination of # emotional posts on a stock.  Relative to normal amount of posts would be a plus.

The problem is sheer volume of mesages on some stocks.  Could do something like Emotion indicator.  As well as a percenrage increase in emotion from the day prior list as well.  Up[dating daily.  


12) Pages on the site would be 1) Overall Emotion.  2) Biggest emotion gainers from 1 day ago.  3)  Biggest emotion gainers from 1 week ago.  4) My Watchlist.  5) Login/Authentiation.  


13) Get app out the door, then iterate and find iprovements to the deep learning algorithm.  psot to elitetrader for ideas.  Another tab for braggart stocks.  This is in remission cause its just gonna be the i told you so posts.  

"bridging open source tech and closed talk trading"

1) Get data into jupyter
2) Remove spam bots
3) Preproccess data. remove junk characters
4) Start marking data.  


14) rewrite script using python.  Automatically runs every hour.  On our own dedicated server?

15)


===

1) remove special characters.  
2) (optional) exclamation point, question mark, capital letters become a seperate column
3) import bot accounts
4) Filter out messages with username bot account.
5) (optional)

6) just do bullish v bearish?
7) So far we have confident, unsure, bullish, bearish

8) Confident vs not.  Happy, told you so,



# Obtaining an Access Token

$ curl -X GET -u bob_sacomano -p https://api.stocktwits.com/api/2/oauth/authorize -d 'client_id=651caeb8c2ee8f1a&response_type=token&redirect_uri=http://www.example.com&scope=read,watch_lists,publish_messages,publish_watch_lists,follow_users,follow_stocks'

# host password is the consumer secret.  Documentation here;
https://api.stocktwits.com/developers/docs/api#oauth-authorize-docs

### To run the server permenantly on ec2

```bash
$ killall -9 node $ kill all node processes
$ node index.js
$ #press CTRL + Z
$ bg %1
```
