(function() {
  var $, collapse, default_options, expand, exports, get_context, is_setup, ns, options, toggle, update_display, _ref;
  exports = exports != null ? exports : window;
    if (exports != null) {
    exports;
  } else {
    exports = {};
  };
    if ((_ref = exports.DjangoClientMessages) != null) {
    _ref;
  } else {
    exports.DjangoClientMessages = {};
  };
  ns = exports.DjangoClientMessages;
  $ = jQuery;
  is_setup = false;
  options = null;
  default_options = {
    collapse_on_add: true
  };
  ns.setup = function(new_options) {
    var list, toggler, wrapper;
    if (new_options == null) {
      new_options = default_options;
    }
    options = new_options;
    if (!jQuery) {
      throw Error('jQuery is required');
    }
    if (!is_setup) {
      list = $('.messagelist').eq(0);
      if (!list.length) {
        throw Error('no .messagelist element');
      }
      wrapper = $('<div>').css('position', 'relative');
      list.replaceWith(wrapper);
      list.appendTo(wrapper);
      toggler = $('<a>').attr('href', '#').addClass('toggler').text('[-]').css({
        'position': 'absolute',
        'bottom': '12px',
        'right': '8px'
      });
      wrapper.append(toggler);
      toggler.click(toggle);
      is_setup = true;
    }
    return update_display();
  };
  ns.add = function(msg_class, text) {
    var ctx;
    ctx = get_context();
    if (options.collapse_on_add) {
      collapse();
    }
    return setTimeout((function() {
      var msgs, new_li;
      if (ctx.wrapper.hasClass('collapsed')) {
        msgs = ctx.list.find('li');
        msgs.hide();
      }
      new_li = $('<li>').addClass(msg_class).text(text).hide().appendTo(ctx.list).fadeIn();
      return update_display();
    }), 100);
  };
  collapse = function() {
    var ctx;
    ctx = get_context();
    ctx.msgs.slice(0, -1).slideUp('fast');
    ctx.wrapper.addClass('collapsed');
    return update_display();
  };
  expand = function() {
    var ctx;
    ctx = get_context();
    ctx.wrapper.removeClass('collapsed');
    ctx.msgs.slice(0, -1).slideDown('fast');
    return update_display();
  };
  update_display = function() {
    var ctx, more_count, plural;
    ctx = get_context();
    if (ctx.wrapper.hasClass('collapsed')) {
      more_count = ctx.msgs.length - 1;
      plural = more_count > 1 ? "s" : "";
      ctx.toggler.text("" + more_count + " more message" + plural + " [+]");
    } else {
      ctx.toggler.text('[-]');
    }
    if (ctx.msgs.length < 2) {
      ctx.toggler.hide('');
    } else {
      ctx.toggler.show();
    }
    ctx.msgs.slice(0, -1).addClass('older');
    return ctx.msgs.eq(-1).removeClass('older');
  };
  toggle = function() {
    var list, wrapper;
    list = $('.messagelist').eq(0);
    wrapper = list.parent();
    if (wrapper.hasClass('collapsed')) {
      expand();
    } else {
      collapse();
    }
    return false;
  };
  get_context = function() {
    var context, list, msgs, toggler, wrapper;
    if (!is_setup) {
      ns.setup();
    }
    list = $('.messagelist').eq(0);
    if (!list.length) {
      throw Error('no .messagelist');
    }
    wrapper = list.parent();
    toggler = wrapper.find('.toggler').eq(0);
    msgs = list.find('li');
    context = {
      list: list,
      wrapper: wrapper,
      toggler: toggler,
      msgs: msgs
    };
    return context;
  };
}).call(this);
