module.exports = exports = ->
    div '#modal-holder', ''
    ul '#toolbar.toolbar.autoload', data: {class: 'UIToolbar'}, ->
      li '.toolbar-logo', data: {class: 'UIToolbarLogo'}, ->
        h1 ->
          a href: '/', 'Sellsto.me'
      li '#new-ad-button.toolbar-button', data: {class: 'UIToolbarButton'}
      li '.toolbar-separator', data: {class: 'UIToolbarSeparator'}
      li '#search.toolbar-search', data: {class: 'UIToolbarSearch'}, ->
        input '.search-input', type: 'text', name: 'search', value: '', placeholder: 'Search'
        div '#search-button.search-button', ''
      li '#pref-button.toolbar-button.right', data: {class: 'UIToolbarButton'}
      li '#followers-button.toolbar-button.right', data: {class: 'UIToolbarButton'}
    ul '#sidebar.sidebar.autoload', data: {class: 'UISidebar', 'content-view': 'content-view'}, ->
      li '#list-sidebar-button.sidebar-button.selected', data: {class: 'UISidebarButton', 'content-block': 'list-block'}
      li '#mine-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'mine-block'}
      li '.sidebar-separator', data: {class: 'UISidebarSeparator'}
      li '#messages-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'messages-block'}
      li '#card-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'card-block'}
      li '#like-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'like-block'}
      li '.sidebar-separator', data: {class: 'UISidebarSeparator'}
      li '#search-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'search-block'}
    ul '#content-view.content-view.autoload', data: {class: 'UIContentView'}, ->
      li '#list-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '#ad-list.ad-list.autoload', data: {class: 'UIAdList'}
        div '#ad-list-map.map.autoload', data: {class: 'UIMap'}
      li '#mine-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '.fish', ->
          h1 '2 — mine page'
      li '#messages-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '.fish', ->
          h1 '3 - messages page'
      li '#card-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '.fish', ->
          h1 '4 - card page'
      li '#like-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '.fish', ->
          h1 '5 - like page'
      li '#search-block.content-block', data: {class: 'UIContentBlock'}, ->
        div '.fish', ->
          h1 '6 — search page'