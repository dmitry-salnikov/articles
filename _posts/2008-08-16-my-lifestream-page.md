---
layout: post
title: my lifestream page
summary: In which I write a simple lifestream page in javascript
---

For a while I've wanted to mash-up the different services I use on a single page. My first attempt was with <a href="http://plagger.org/trac">plagger</a>, and publishing all the information on my google calendar. That wasn't really interesting, as I don't need to archived all this stuff. After this one, I've tried to make a static page, using <a href="http://developer.yahoo.com/yui/">the yahoo! library interface</a> stuff. A page with tabs, each tabs for a service. The content was generated with Plagger and Template Toolkit. It was working fine, but I had to do some HTML, check why some some stuff were not working, etc. And as I'm not a designer, and as I'm incapable to think a good user interface, I was quickly fed up with this solution.

I use <a href="http://pipes.yahoo.com/pipes/">yahoo! pipes</a> for mashing some feeds, and saw that you can get a result from your feed in JSON. I've started to think about a simple page with just some javascript, a simple css, and using the JSON result. So I've created a feed that combine the services that I use (<a title="pipe" href="http://pipes.yahoo.com/franckcuny/myfeeds " target="_blank">the pipe is here</a>), created <a href="http://franck.breizhdev.net/">a simple HTML page</a>, read some jquery documentation on how to read a JSON file, and created this page. The code is really simple. For the flickr stream, I use the code generated from the <a title="flickr badge generator" href="http://www.flickr.com/badge.gne">badge generator</a>. I've done some modifications, like removing the table, removing some classes, altering the css, ... The remaining code is


{% highlight html %}
<div id="flickr_badge_uber_wrapper">
    <script src="http://www.flickr.com/badge_code_v2.gne?count=9&display=latest&size=s&layout=h&source=user&user=27734462%40N00" type="text/javascript"></script></div>
{% endhighlight %}

For displaying the result of the JSON feed, I've found some simple code, that I've modified a bit to feet my purpose.

{% highlight javascript %}
$(function(){
   var CssToAdd = new Object();
    $.getJSON('http://pipes.yahoo.com/pipes/pipe.run?_id=NMLU4MNq3RGDW_8fpwt1Yg&_render=json&_callback=?',
   function(data){
            $('div#loading-area').hide('fast');
      $.each(data.value.items, function(i,item){
          var a_class;

          try {
        if (item.link.match(/last/)) {
            a_class = 'lastfm';
        }else if (item.link.match(/pownce/)) {
            a_class = 'lastfm';
        }else if (item.link.match(/breizhdev/)) {
            a_class = 'blog';
        }else if (item.id.content.match(/google/)) {
            a_class = 'greader';
        }else{
            a_class = 'delicious';
        }
        }catch(err){
            a_class = 'delicious';
        }

         $('<a>').attr('href',item.link).text(item.title).addClass(a_class).appendTo('#sample-feed-block');
      });
    $('#sample-feed-block a').wrapAll('<ul>').wrap('<li>');
    });
});
{% endhighlight %}

As my javascript's skills are near 0, I've no doubt that there is some better way to do this. Feel free to send me a patch ;)

The page is available <a href="http://franck.breizhdev.net/">here</a>.

If you want to copy this page, and use your own pipe, don't forget to append "<strong>=json&amp;_callback=?</strong>" at the end of the url of the JSON version of the feed.

The thing that I really like with this page, it's that everything fit in a single HTML file. The jquery.min.js is hosted on the <a title="jquery" href="http://jquery.com">jquery site</a>, the icons are favicons pulled directly from the sites, so anyone can juste copy this page, change the address of the pipe, modify the flickr call, play a bit with the embded CSS, and it's done.
