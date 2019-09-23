import React from "react"
import MapContext from "../context/MapContext"
import { FormattedMessage } from "gatsby-plugin-intl"

const MapOverlay = () => {
  return (
    <MapContext.Consumer>
      {mapState => {
        console.log(mapState)
        const opacity = (mapState.selectedLayer === "municipales-not-found-count-init") ? 1 : 0
        return (<div className="map-overlay" style={{ opacity: opacity }}>
          <h1><FormattedMessage id="overlayTitle" /></h1>
          <h2><FormattedMessage id="overlayCredit" /></h2>
          <h3><FormattedMessage id="overlayDate" /></h3>
        </div>)
      }}
    </MapContext.Consumer>
  )
}

export default MapOverlay
