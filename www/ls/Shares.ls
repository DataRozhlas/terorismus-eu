class ig.Shares
  (@parentElement) ->
    shareUrl = window.location
    @element = @parentElement.append \div
      ..attr \class \shares
      ..html "<a class='share cro' title='Zpět nahoru' href='http://www.rozhlas.cz/zpravy/data/'><img src='https://samizdat.cz/tools/cro-logo/cro-logo-light.svg'></a>
              <a class='share fb' title='Sdílet na Facebooku' target='_blank' href='https://www.facebook.com/sharer/sharer.php?u=#shareUrl'><img src='https://samizdat.cz/tools/icons/facebook-bg-white.svg'></a>
              <a class='share tw' title='Sdílet na Twitteru' target='_blank' href='https://twitter.com/home?status=#shareUrl'><img src='https://samizdat.cz/tools/icons/twitter-bg-white.svg'></a>"

    @element.select "a[target='_blank']" .on \click ->
      window.open do
        @getAttribute \href
        ''
        "width=550,height=265"
