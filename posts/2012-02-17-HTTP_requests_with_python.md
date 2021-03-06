Hey! I'm alive!
---------------

I've started to write some Python for work, and since I'm new at the game, I've decided to start using it for some personal project too.

Most of what I do is related to web stuff: writing API, API client, web framweork, etc. At [Say](http://www.saymedia.com/) I'm working on our platform. Nothing fancy, but really interesting (at least to me) and challenging work (and we're recruting, drop me a mail if you want to know more).

Writing HTTP requests with Python
---------------------------------

### httplib

[httplib](http://docs.python.org/library/httplib.html) is part of the standard library. The documentation says: *It is normally not used directly*. And when you look at the API you understand why: it's very low-level. It uses the HTTPMessage library (not documented, and not easily accessible). It will return an HTTPResponse object, but again, no documentation, and poor interface.

### httplib2

[httplib2](http://code.google.com/p/httplib2/) is a very popular library for writing HTTP request with Python. It's the one used by Google for it's [google-api-python-client](http://code.google.com/p/google-api-python-client/) library. There's absolutly nothing in common between httplib's API and this one.

I dont like it's API: the way the library handles the **Response** object seems wrong to me. You should get one object for the response, not a tuple with the response and the content. The request should also be an object. Also, The status code is considered as a header, and you lose the message that comes with the status.

There is also an important issue with httplib2 that we discovered at work. In some case, if there is an error, httplib2 will retry the request. That means, in the case of a POST request, it will send twice the payload. There is [a ticket that ask to fix that](http://code.google.com/p/httplib2/issues/detail?id=124), marked as **won't fix**. [Even when there is a perfectly acceptable patch for this issue.](http://codereview.appspot.com/4365054/) (it's a [WAT](https://www.destroyallsoftware.com/talks/wat) moment). I'm really curious to know what was the motiviation behind this, because it doesn'nt makes sense at all. Why would you want your client to retry twice your request if it fails ?

### urllib

[urllib](http://docs.python.org/library/urllib.html) is also part of the standard library. I was suprised, because given the name, I was expecting a lib to *manipulate* an URL. And indeed, it also does that! This library mix too many different things.

### urllib2

[urllib2](http://docs.python.org/library/urllib2.html) And because 2 is not enough, also ...

### urllib3

[urllib3](http://code.google.com/p/urllib3/). I thought for a moment that, maybe, the number number was related to the version of Python. I'll spare you the suspense, it's not the case. Now I would have expected them to be related to each other (sharing some common API, the number being just a way to provides a better API than the previous version). Sadly it's not the case, they all implement different API.

At least, urllib3 has some interesting features:

-   Thread-safe connection pooling and re-using with HTTP/1.1 keep-alive
-   HTTP and HTTPS (SSL) support

### request

A few persons pointed me to [requests](http://pypi.python.org/pypi/requests). And indeed, this one is the nicest of all. Still, not exactly what *I*'m looking for. This library looks like [LWP::Simple](https://metacpan.org/module/LWP::Simple), a library build on top of various HTTP components to help you for the common case. For most of the developers it will be fine and do the work as intented.

What I want
-----------

Since I'm primarly a Perl developer (here is were 99% of the readers are leaving the page), I've been using [LWP](https://metacpan.org/module/LWP) and <HTTP::Messages> for more than 8 years. LWP is an awesome library. It's 16 years old, and it's still actively developed by it's original author [Gisle Aas](https://metacpan.org/author/GAAS). He deserves a lot of respect for his dedication.

There is a few other library in Perl to do HTTP request, like:

\[\[<https://metacpan.org/module/AnyEvent>  
HTTP\]\[AnyEvent::HTTP\]\]: if you need to do asynchronous call

-   [Furl](https://metacpan.org/module/Furl): by Tokuhiro and his yakuza gang

but most of the time, you end up using LWP with <HTTP::Messages>.

One of the reason this couple is so popular is because it provides the right abstraction:

a user-agent is provided by LWP  
UserAgent (that you can easily extends to build some custom useragent)

-   a Response class to encapsulates HTTP style responses, provided by <HTTP::Message>
-   a Request class to encapsulates HTTP style request, provided by <HTTP::Message>

The response and request objects use <HTTP::Headers> and <HTTP::Cookies>. This way, even if your building a web framework and not a HTTP client, you'll endup using <HTTP::Headers> and <HTTP::Cookies> since they provide the right API, they're well tested, and you only have to learn one API, wether you're in an HTTP client or a web framework.

http
----

So now you start seeing where I'm going. And you're saying "ho no, don't tell me you're writing *another* HTTP library". Hell yeah, I am (sorry, Masa). But to be honest, I doubt you'll ever use it. It's doing the job *I* want, the way *I* want. And it's probably not what you're expecting.

[http](http://git.lumberjaph.net/py-http.git/) is providing an abstraction for the following things:

-   http.headers
-   http.request
-   http.response
-   http.date
-   http.url (by my good old friend "bl0b":<https://github.com/bl0b>)

I could have named it **httplib3**, but **http** seems a better choice: it's a library that deals with the HTTP protocol and provide abstraction on top of it.

You can found the [documentation here](http://http.readthedocs.org/en/latest/index.html) and install it from [PyPI](http://pypi.python.org/pypi/http/).

### examples

A few examples

``` python
    >>> from http import Request
    >>> r = Request('GET', 'http://lumberjaph.net')
    >>> print r.method
    GET
    >>> print r.url
    http://lumberjaph.net
    >>> r.headers.add('Content-Type', 'application/json')
    >>> print r.headers
    Content-Type: application/json


    >>>
```

``` python
    >>> from http import Headers
    >>> h = Headers()
    >>> print h


    >>> h.add('X-Foo', 'bar')
    >>> h.add('X-Bar', 'baz', 'foobarbaz')
    >>> print h
    X-Foo: bar
    X-Bar: baz
    X-Bar: foobarbaz


    >>> for h in h.items():
    ...     print h
    ...
    ('X-Foo', 'bar')
    ('X-Bar', 'baz')
    ('X-Bar', 'foobarbaz')
    >>>
```

### a client

With this, you can easily build a very simple client combining thoses classes, or a more complex one. Or maybe you want to build a web framework, or a framework to test HTTP stuff, and you need a class to manipulate HTTP headers. Then you can use http.headers. The same if you need to create some HTTP responses: http.response.

I've started to write [httpclient](http://git.lumberjaph.net/py-httpclient.git/) based on this library that will mimic LWP's API.

I've started [to document this library](http://httpclient.readthedocs.org/en/latest/index.html) and I hope to put something on PyPI soon.
