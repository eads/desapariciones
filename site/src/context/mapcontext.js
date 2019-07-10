import React from "react"

const defaultState = {
  data: () => {},
  viewport: () => {},
  card: 0,
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    data: {},
    viewport: {},
    card: 0,
  }

  render() {
    const { children } = this.props
    const { data, viewport, card } = this.state
    return (
      <MapContext.Provider
        value={{
          data, viewport, card
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
