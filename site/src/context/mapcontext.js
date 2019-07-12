import React from "react"
import { uniq, groupBy, sumBy, sortBy, throttle } from "lodash"

const defaultState = {
  data: {},
  stateSummary: [],
  setData: () => {},
  viewport: {},
  setViewport: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    data: {},
    stateSummary: [],
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.9,
      latitude: 23.42,
      zoom: 3.1,
    },
  }

  setData = ({data}) => {
    const features = uniq(data, "properties.id")
    const states = groupBy(features, "properties.nom_ent")
    const stateSummary = sortBy(Object.keys(states).map( (k) => { return {
      state: k,
      disappearances: sumBy(states[k], "properties.disappearance_count")
    }}), "disappearances").reverse()
    this.setState({data, stateSummary})
  }

  render() {
    const { children } = this.props
    const { data, viewport, stateSummary } = this.state
    //const throttledSetData = throttle(this.setData, 200)

    return (
      <MapContext.Provider
        value={{
          data,
          stateSummary,
          viewport,
          setViewport: (viewport) => this.setState({viewport}),
          setData: (data) => this.setData({data}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
