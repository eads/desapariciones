import React from "react"
import MapContext from "../context/MapContext"

import find from "lodash/find"
import partition from "lodash/partition"
import zip from "lodash/zip"

class MapLegend extends React.Component {
  render() {
    const { layer } = this.props
    return (
      <div className="card-legend">
        <MapContext.Consumer>
          {mapState => {
            const selectedLayer = find(mapState.style.layers, {"id": layer})
            if (!selectedLayer) return null

            // partition mapbox style's (val, colorcode) pattern
            const partitioned = partition(selectedLayer.paint["fill-color"].slice(3), (o) => parseFloat(o))

            // zip partitioned back into k, v objects
            const legendItems = zip(...partitioned).map( d => ({color: d[1], value: d[0]}) )

            return (<>
              {legendItems.map( (item, i) => (
                <div key={`item-${i}`}>
                  <span className="legend-box" style={{backgroundColor:item.color}} />
                  {item.value}
                </div>
              ))}
            </>)
          }}
        </MapContext.Consumer>
      </div>
    )
  }
}

export default MapLegend

/*

  cardLegend = () => {
    const { mapState } = this.props
    const layer = find(mapState.style.layers, {"id": mapState.selectedLayer})
    if (!layer) return null

    // This is... inelegant
    const legendItems = zip(...partition(layer.paint["fill-color"].slice(3), (o) => parseFloat(o) ))
                          .map( (d) => ({color: d[1], value: d[0]}) )

    return (<>
      {legendItems.map( (item, i) => (
        <div key={`item-${i}`}>
          <span className="legend-box" style={{backgroundColor:item.color}} />
          {item.value}
        </div>
      ))}
    </>)
  }

 */
