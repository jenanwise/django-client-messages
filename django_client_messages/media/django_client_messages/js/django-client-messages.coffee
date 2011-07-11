# Client-side message system unified with Django's messages system.
#
# Include this script in a page, and then you can you add messages to the
# message list from client-side code:
#
#     DjangoClientMessages.add('success', 'Added 12 foos to the bar.')
#     DjangoClientMessages.add('error', 'Something is terribly wrong.')
#
# The `add()` function is analogous to Django's messages.add_message()
# function. The first argument is the level/class, and the second is the
# message.
#
# Requirements:
#
#  * a `<ul>` with the "messagelist" class
#  * jQuery
#
# Optional:
#
#  * the packaged css, for more-distinguished message classes
#
# The code currently only works with the first .messagelist element on the
# page. If there is no such element, DjangoClientMessages will do nothing! By
# default, if there are no messages on the server-side, Django's admin template
# will *NOT* create a `<ul class="messagelist>`. So if you want
# DjangoClientMessages to work properly in your admin pages, you need to
# override the base admin template or use javascript to always ensure there is
# a `<ul class="messagelist">` on your page before calling DjangoClientMessages
# functions. DjangoClientMessages cannot create the element for you, since it
# doesn't know where to put it!

#### Namespace setup
exports = exports ? window
exports ?= {}
exports.DjangoClientMessages ?= {}
ns = exports.DjangoClientMessages


# Module-level variables
$ = jQuery
is_setup = false
options = null
default_options =
    collapse_on_add: true

#### Primary API

# Setup the messages list options, page elements, and callbacks.
#
# Multiple calls to setup() are okay. The first call will create the required
# page elements and set the options. Subsequent calls will just change the
# options.
#
# Calling setup() directly is not required. It will be called automatically by
# any function that needs it.
ns.setup = (new_options = default_options) ->
    options = new_options

    if not jQuery
        throw Error('jQuery is required')

    if not is_setup
        list = $('.messagelist').eq(0)
        if not list.length
            throw Error('no .messagelist element')

        wrapper = $('<div>').css('position', 'relative')
        list.replaceWith(wrapper)
        list.appendTo(wrapper)

        toggler = $('<a>')
            .attr('href', '#')
            .addClass('toggler')
            .text('[-]')
            .css(
                'position': 'absolute'
                'bottom': '12px'
                'right': '8px'
            )
        wrapper.append(toggler)
        toggler.click(toggle)

        is_setup = true

    update_display()


# Add a message to the list.
#
# msg_class can be any class you want, but for a unified look and feel it
# should match one of Django's messages classes. If you use the included styles
# then "success", "error", "warning", and "info" will all be usefully-styled
# and any other message class will have a grey background.
ns.add = (msg_class, text) ->
    ctx = get_context()
    collapse() if options.collapse_on_add

    # Slight delay on the fade in of new message so that the collapsing
    # messages can finish their animation and we are more drawn visually to the
    # new message. The proper way to do this is probably by chaining jQuery
    # animation callbacks, but this is simple and it works.
    setTimeout((->
        if ctx.wrapper.hasClass('collapsed')
            msgs = ctx.list.find('li')
            msgs.hide()

        new_li = $('<li>')
            .addClass(msg_class)
            .text(text)
            .hide()
            .appendTo(ctx.list)
            .fadeIn()

        update_display()
    ), 100)


#### Helpers

# Collapse the messages list down to one message.
#
# If there are more remaining, a "N more message [+]" link will be shown.
collapse = () ->
    ctx = get_context()
    ctx.msgs.slice(0, -1).slideUp('fast')
    ctx.wrapper.addClass('collapsed')
    update_display()


# Expand the messages list.
#
# If there are more than 1 messages available, a collapse "[-]" link will be
# shown.
expand = () ->
    ctx = get_context()
    ctx.wrapper.removeClass('collapsed')
    ctx.msgs.slice(0, -1).slideDown('fast')
    update_display()


# Update display state.
#
# This sets the text of the toggler link and puts an "older" class on the
# non-latest messages.
update_display = () ->
    ctx = get_context()

    if ctx.wrapper.hasClass('collapsed')
        more_count = ctx.msgs.length - 1
        plural = if more_count > 1 then "s" else ""
        ctx.toggler.text("#{more_count} more message#{plural} [+]")
    else
        ctx.toggler.text('[-]')

    # Only show toggler if we have 2+ messages.
    if ctx.msgs.length < 2
        ctx.toggler.hide('')
    else
        ctx.toggler.show()

    # Non-latest messages get "older" class.
    ctx.msgs.slice(0, -1).addClass('older')
    ctx.msgs.eq(-1).removeClass('older')


# Toggle the collapsed/expanded state of the message list.
toggle = () ->
    list = $('.messagelist').eq(0)
    wrapper = list.parent()

    if wrapper.hasClass('collapsed')
        expand()
    else
        collapse()

    return false


# Get standard page context and setup if necessary.
get_context = ->
    if not is_setup
        ns.setup()

    list = $('.messagelist').eq(0)
    if not list.length
        throw Error('no .messagelist')

    wrapper = list.parent()
    toggler = wrapper.find('.toggler').eq(0)
    msgs = list.find('li')

    context =
        list: list
        wrapper: wrapper
        toggler: toggler
        msgs: msgs

    return context
