import React from "react"
import MapContext from "../context/MapContext"

class ViewportIndicator extends React.Component {

  render() {
    return (<div className="viewport-indicator">
      <MapContext.Consumer>
      {mapState => {
        if (mapState.data.length && mapState.stateSummary.length === 32 && mapState.data.length === 1417) {
          return <p>Showing all {mapState.data.length} municipalities in all 32 states</p>
        } else if (mapState.data.length && mapState.stateSummary.length === 32) {
          return <p>Showing {mapState.data.length} municipalities in all 32 states</p>
        } else if (mapState.data.length) {
          const states = mapState.stateSummary.map( d => d.state )
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
    </div>)
  }
}

export default ViewportIndicator
