---
layout: static
title: List of articles
---

<div id='wrapper'>
    <h3>Posts</h3>

    <ul>
    {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      <span class="date">{{ post.date | date_to_string }}</span>
    </li>
    {% endfor %}
    </ul>

</div>
