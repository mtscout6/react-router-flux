require '../style.css'

React = require 'react'
Routes = require './routes'

context = {}

# Enable Chrome Dev Tools
global.React = React

React.renderComponent React.withContext(context, -> <Routes />), document.body
