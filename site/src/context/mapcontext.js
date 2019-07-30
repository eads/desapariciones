import React from "react"
import { throttle } from "lodash"

const defaultState = {
  selectedLayer: "",
  data: {},
  viewport: {},
  setData: () => {},
  setViewport: () => {},
  setSelectedLayer: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    selectedLayer: "municipales-not-found-count",
    data: {},
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.0,
      latitude: 22.5,
      zoom: 3.05,
      pitch: 0,
    },
  }

  render() {
    const { children } = this.props
    const { data, viewport, selectedLayer } = this.state

    return (
      <MapContext.Provider
        value={{
          selectedLayer,
          data,
          viewport,
          setViewport: (viewport) => this.setState({viewport}),
          setData: (data) => this.setState({data}),
          setSelectedLayer: (selectedLayer) => this.setState({selectedLayer}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
