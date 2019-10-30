import React from "react"
import MapContext from "../context/MapContext"

import find from "lodash/find"
import partition from "lodash/partition"
import zip from "lodash/zip"

class MapLegend extends React.Component {
  render() { return <h3>legend</h3> }
  //render() {
    //return (
      //<div className="map-legend">
        //<MapContext.Consumer>
          //{mapState => {
            //const selectedLayer = find(mapState.style.layers, {"id": mapState.selectedLayer})
            //if (!selectedLayer) return null

            //// partition mapbox style's (val, colorcode) pattern
            //const partitioned = partition(selectedLayer.paint["fill-color"].slice(3), (o) => parseFloat(o))

            //// zip partitioned back into k, v objects
            //const legendItems = zip(...partitioned).map( d => ({color: d[1], value: d[0]}) )

            //return (<>
              //<h2>Legend</h2>
              //{legendItems.reverse().map( (item, i) => (
                //<div key={`item-${i}`}>
                  //{item.value}
                  //<span className="legend-box" style={{backgroundColor:item.color}} />
                //</div>
              //))}
            //</>)
          //}}
        //</MapContext.Consumer>
      //</div>
    //)
  //}
}

export default MapLegend
