import React from "react"
import MapContext from "../context/MapContext"
import { groupBy, sumBy, sortBy } from "lodash"

class ViewportIndicator extends React.Component {

  stateSummary = (data) => {
    const states = groupBy(data, "properties.nom_ent")
    return sortBy(Object.keys(states).map( (k) => { return {
      state: k,
      disappearances: sumBy(states[k], "properties.disappearance_ct")
    }}), "disappearances").reverse()
  }

  render() {
    return (
      <div className="viewport-indicator">
        <MapContext.Consumer>
          {mapState => {
            const stateSummary = this.stateSummary(mapState.data)

            if (mapState.data.length && stateSummary.length === 32 && mapState.data.length === 1417) {
              return <p>Showing all {mapState.data.length} municipalities in all 32 states</p>
            } else if (mapState.data.length && stateSummary.length === 32) {
              return <p>Showing {mapState.data.length} municipalities in all 32 states</p>
            } else if (mapState.data.length) {
              const states = stateSummary.map( d => d.state )
              const numStates = states.length
              if (numStates > 4) {
                return <p>Showing {mapState.data.length} municipalities in {states.slice(0, 4).join(', ')} and {numStates - 4} more</p>
              } else {
                return <p>Showing {mapState.data.length} municipalities in {states.join(', ')}</p>
              }
            } else {
              return null
            }
          }}
        </MapContext.Consumer>
      </div>
    )
  }
}

export default ViewportIndicator
