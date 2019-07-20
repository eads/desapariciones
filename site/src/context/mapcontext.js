import React from "react"
import { uniq, groupBy, sumBy, sortBy, throttle } from "lodash"

const defaultState = {
  data: {},
  stateSummary: [],
  genderSummary: [],
  setData: () => {},
  viewport: {},
  setViewport: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    data: {},
    stateSummary: [],
    genderSummary: [],
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.0,
      latitude: 22.5,
      zoom: 3.05,
      pitch: 0,
    },
  }

  setData = ({data}) => {
    const states = groupBy(data, "properties.nom_ent")

    const stateSummary = sortBy(Object.keys(states).map( (k) => { return {
      state: k,
      disappearances: sumBy(states[k], "properties.disappearance_count")
    }}), "disappearances").reverse()


    const genderCount = {
      m: 0,
      f: 0,
      n: 0,
    }
    data.forEach( (d) => {
      if (d.properties.gender_fem_ct) genderCount.f += d.properties.gender_fem_ct
      if (d.properties.gender_masc_ct) genderCount.m += d.properties.gender_masc_ct
      if (d.properties.gender_null_ct) genderCount.n += d.properties.gender_null_ct
    })

    const genderSummary = [
      { name: 'm', value: genderCount.m },
      { name: 'f', value: genderCount.f },
    ]

    this.setState({data, stateSummary, genderSummary})
  }

  render() {
    const { children } = this.props
    const { data, viewport, stateSummary, genderSummary } = this.state
    const throttledSetData = throttle(this.setData, 500)

    return (
      <MapContext.Provider
        value={{
          data,
          stateSummary,
          genderSummary,
          viewport,
          setViewport: (viewport) => this.setState({viewport}),
          setData: (data) => throttledSetData({data}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
