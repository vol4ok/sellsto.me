module.exports = exports = ->
  div '#modal-underlay.modal-underlay.autoload', data: {class: 'UIModalUnderlay'}
  div '.modal-holder-wrap', ->
    div '#modal-holder.modal-holder', ->
      div '#new-ad-modal.modal.autoload', data: {class: 'UINewAdModal'}, ->
        div '.body', ->
          # div '.x.close', ''
          form ->
            fieldset ->
              textarea '#message.message', name: 'message', autofocus: yes, ''
              ul ->
                li '.input', ->
                  label for: 'price', 'Price:'
                  input '#price-input', name: 'price', maxlength: '5'
                  a '.inherit', href:'#', rel: 'UIPopover', data: { popover: 'UIСurrencyPopover' }, 'руб.'
                li '.input', ->
                  label for: 'count', 'Quantity:'
                  input '#quantity-input', name: 'count', maxlength: '5'
                  text 'items'
                li '.button.right', rel: 'UITooltip', 'data-title': 'Drag photos here', ->           
                  a '#photo-button', href: '#', ''
                li '.button.right', rel: 'UITooltip', 'data-title': 'Add video URL', ->           
                  a '#video-button', href: '#', ''
        div '.footer', ->
          button '.submit.right.btn.primary.disabled', 'Create'
          div '.counter.right', '400'
          button '.close.left.btn', 'Cancel'
      div '#pref-modal.modal.autoload', data: { class: 'UIPrefModal' }, ->
        
        div 'ui-textedit', ->
          input type: 'text'
        br()
        div '.ui-select.autoload', data: { class: 'UISelectBox' }, ->
          span 'Select data'
          select -> 
            option value: 'never', 'Never'
            option value: 'auto', 'Auto'
            option value: 'manual', 'Manual'
        br()
        div '.ui-upload', ->
          span 'Upload'
          input type: 'file'
      div '#followers-modal.modal.autoload', data: { class: 'UIFollowersModal' }
  ul '#toolbar.toolbar.autoload', data: {class: 'UIToolbar'}, ->
    li '.toolbar-logo', data: {class: 'UIToolbarLogo'}, ->
      h1 ->
        a href: '/', 'Sellsto.me'
    li '#new-ad-button.toolbar-button', data: {class: 'UIToolbarButton'}
    li '.toolbar-separator', data: {class: 'UIToolbarSeparator'}
    li '#search.toolbar-search', data: {class: 'UIToolbarSearch'}, ->
      input '.search-input', type: 'text', name: 'search', value: '', placeholder: 'Search'
      div '#search-button.search-button.disabled', ''
    li '#pref-button.toolbar-button.right', data: {class: 'UIToolbarButton'}
    li '#followers-button.toolbar-button.right', data: {class: 'UIToolbarButton'}
  ul '#sidebar.sidebar.autoload', data: {class: 'UISidebar', 'content-view': 'content-view'}, ->
    li '#list-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'list-block'}
    li '#mine-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'mine-block'}
    li '.sidebar-separator', data: {class: 'UISidebarSeparator'}
    li '#messages-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'messages-block'}
    li '#card-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'card-block'}
    li '#like-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'like-block'}
    li '.sidebar-separator', data: {class: 'UISidebarSeparator'}
    li '#search-sidebar-button.sidebar-button', data: {class: 'UISidebarButton', 'content-block': 'search-block'}
  ul '#content-view.content-view.autoload', data: {class: 'UIContentView'}, ->
    li '#list-block.content-block.default', data: {class: 'UIContentBlock'}, ->
      div '.ad-list-wrap', ->
        ul '#ad-list.ad-list.autoload', data: {class: 'UIAdList'}
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
        div '.ad-list-wrap', ->
          ul '#search-list.ad-list.autoload', data: {class: 'UIAdList'}
        div '#search-list-map.map.autoload', data: {class: 'UIMap'}