React = require 'react'
RouterConstants = require '../constants/RouterConstants'
Logger = require '../utils/logger'

LocationAttempt =
  contextTypes:
    router: React.PropTypes.object.isRequired

  getInitialState: ->
    LocationAttempt:
      attemptDispatchToken: @context.router.dispatcher.register @locationAttemptDispatcherHandler

  componentWillUnmount: ->
    if @state.LocationAttempt.attemptDispatchToken?
      @context.router.dispatcher.unregister @state.LocationAttempt.attemptDispatchToken

  locationAttemptDispatcherHandler: (payload) ->
    return unless @isMounted()

    @context.router.dispatcher.waitFor [
      @context.router.stores.location.dispatchToken
    ]

    @dismissLocationAttempt() unless @context.router.stores.location.isBlocked() or payload?.action?.actionType == RouterConstants.LOCATION_UNBLOCK

    return unless payload?.action?.actionType == RouterConstants.LOCATION_ATTEMPT

    lastAttempt = payload.action.originalAction
    lastAttempt.fromLocationEvent = false

    @setState
      LocationAttempt:
        lastAttempt: lastAttempt

    @handleLocationAttempt() if @handleLocationAttempt

  dismissLocationAttempt: ->
    @setState
      LocationAttempt:
        lastAttempt: null

    @handleLocationAttemptDismissed() if @handleLocationAttemptDismissed

  # Ensure responsible blocks are removed first
  continueLocationAttempt: ->
    return unless @state.LocationAttempt.lastAttempt?

    if @context.router.stores.location.isBlocked()
      Logger.development.warn 'Continuing transition when the location store is still blocked!'

    @dismissLocationAttempt()
    @context.router.actions._dispatch @state.LocationAttempt.lastAttempt

module.exports = LocationAttempt
