Die, damn hotlinkers!
=====================

by Sunny Ripert - sunfox.org

Use it against an HTTP log to find out who points directly towards your files

Usage
------

    $ ruby damn_hotlinkers.rb [--days=DAYS_AGO] [--html] file.log [file2.log ...]

Examples
--------

    $ ruby damn_hotlinkers.rb http.log
    http://yourdomain.com/images/longcat.jpg
      -> http://evil.org/hotlinkingpagebooh.html
      -> http://catimages.com/
    
    $ ruby damn_hotlinkers.rb --days=2 --html http.log
    <ul>
      <li>
        <a href='http://yourdomain.com/images/longcat.jpg'>
          http://yourdomain.com/images/longcat.jpg
        </a>
        <ul>
          <li>
            <a href='http://catimages.com/'>
            http://catimages.com/
            </a>
          </li>
        </ul>
      </li>
    </ul>

