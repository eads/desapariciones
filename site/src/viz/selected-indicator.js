import React from "react"
import MapContext from "../context/MapContext"

class SelectedIndicator extends React.Component {

  render() {
    return (
      <div className="selected-indicator">
        <MapContext.Consumer>
          {mapState => (
            <>{mapState.selectedEstado}</>
          )}
        </MapContext.Consumer>
      </div>
    )
  }
}

export default SelectedIndicator
