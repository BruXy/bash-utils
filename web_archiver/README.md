Web scrapping idea for bash
===========================

This script works with cooperation with Chrome plug-in
[EditThisCookie](http://www.editthiscookie.com/). Once you will login to some
site, you will receive a cookie, which is then sent back by your browser to the
server. A cookie usually contains some information processes by server about your
current session, authentication and time validity.

Usually, you don't need to care about cookie content, you just need to provide
it back to the server. EditThisCookie can export existing cookie in JSON format
and you just need to provide name and value back in Cookie header:

```bash
curl --cookie "name1=value; name2=another" URL
```

Before using the script, save a cookie to file `init_cookie.json`.

The script contains variable `URL_FORMAT` with the example of scrapping some
file with incrementing number. It is also smart to provide different `AGENT`
string instead of `curl` identification. I prefer to scrape pages one by one,
without any parallel request sending or another aggressive method which may be
detected on the server-side as something unusual.

