var exports;
module.exports = exports = function() {
  div('#modal-underlay.modal-underlay.autoload', {
    data: {
      "class": 'UIModalUnderlay'
    }
  });
  div('.modal-holder-wrap', function() {
    return div('#modal-holder.modal-holder', function() {
      return div('#new-ad-modal.modal.autoload', {
        data: {
          "class": 'UINewAdModal'
        }
      }, function() {
        return form(function() {
          return fieldset(function() {
            div('.body', function() {
              textarea('.message', '');
              return ul(function() {
                return li(function() {
                  label({
                    "for": 'price'
                  }, 'Price:');
                  sup('$');
                  return input('.price', {
                    name: 'price',
                    maxlength: '5'
                  });
                });
              });
            });
            return div('.footer', function() {
              button('.submit.right.btn.primary.disabled', 'Create');
              return button('.close.left.btn', 'Cancel');
            });
          });
        });
      });
    });
  });
  ul('#toolbar.toolbar.autoload', {
    data: {
      "class": 'UIToolbar'
    }
  }, function() {
    li('.toolbar-logo', {
      data: {
        "class": 'UIToolbarLogo'
      }
    }, function() {
      return h1(function() {
        return a({
          href: '/'
        }, 'Sellsto.me');
      });
    });
    li('#new-ad-button.toolbar-button', {
      data: {
        "class": 'UIToolbarButton',
        event: 'new-ad'
      }
    });
    li('.toolbar-separator', {
      data: {
        "class": 'UIToolbarSeparator'
      }
    });
    li('#search.toolbar-search', {
      data: {
        "class": 'UIToolbarSearch',
        event: 'search'
      }
    }, function() {
      input('.search-input', {
        type: 'text',
        name: 'search',
        value: '',
        placeholder: 'Search'
      });
      return div('#search-button.search-button', '');
    });
    li('#pref-button.toolbar-button.right', {
      data: {
        "class": 'UIToolbarButton',
        event: 'pref'
      }
    });
    return li('#followers-button.toolbar-button.right', {
      data: {
        "class": 'UIToolbarButton',
        event: 'followers'
      }
    });
  });
  ul('#sidebar.sidebar.autoload', {
    data: {
      "class": 'UISidebar',
      'content-view': 'content-view'
    }
  }, function() {
    li('#list-sidebar-button.sidebar-button.selected', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'list-block'
      }
    });
    li('#mine-sidebar-button.sidebar-button', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'mine-block'
      }
    });
    li('.sidebar-separator', {
      data: {
        "class": 'UISidebarSeparator'
      }
    });
    li('#messages-sidebar-button.sidebar-button', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'messages-block'
      }
    });
    li('#card-sidebar-button.sidebar-button', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'card-block'
      }
    });
    li('#like-sidebar-button.sidebar-button', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'like-block'
      }
    });
    li('.sidebar-separator', {
      data: {
        "class": 'UISidebarSeparator'
      }
    });
    return li('#search-sidebar-button.sidebar-button', {
      data: {
        "class": 'UISidebarButton',
        'content-block': 'search-block'
      }
    });
  });
  return ul('#content-view.content-view.autoload', {
    data: {
      "class": 'UIContentView'
    }
  }, function() {
    li('#list-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      div('#ad-list.ad-list.autoload', {
        data: {
          "class": 'UIAdList'
        }
      });
      return div('#ad-list-map.map.autoload', {
        data: {
          "class": 'UIMap'
        }
      });
    });
    li('#mine-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      return div('.fish', function() {
        return h1('2 — mine page');
      });
    });
    li('#messages-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      return div('.fish', function() {
        return h1('3 - messages page');
      });
    });
    li('#card-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      return div('.fish', function() {
        return h1('4 - card page');
      });
    });
    li('#like-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      return div('.fish', function() {
        return h1('5 - like page');
      });
    });
    return li('#search-block.content-block', {
      data: {
        "class": 'UIContentBlock'
      }
    }, function() {
      return div('.fish', function() {
        return h1('6 — search page');
      });
    });
  });
};