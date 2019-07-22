import React from "react"
import MapContext from "../context/MapContext"

class ViewportIndicator extends React.Component {

  render() {
    return (<div className="viewport-indicator">
      <MapContext.Consumer>
      {mapState => {
        if (mapState.stateSummary.length == 32) {
          return <p>All states</p>
        } else if (mapState.data.length) {
          const states = mapState.stateSummary.map( d => d.state )
          const numStates = states.length
          if (numStates > 4) {
            return <p>{states.slice(0, 4).join(', ')} and {numStates - 4} more</p>
          } else {
            return <p>{states.join(', ')}</p>
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
